import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MapSection extends StatefulWidget {
  const MapSection({super.key});

  @override
  State<MapSection> createState() => _MapSectionState();
}

class _MapSectionState extends State<MapSection> {
  final MapController _mapController = MapController();
  final supabase = Supabase.instance.client;

  // 🔍 Search
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';

  LatLng? currentLocation;
  final double _zoom = 13;

  Timer? _friendsTimer;

  String? avatarUrl;
  String? username;
  List<Map<String, dynamic>> friendsLocations = [];

  String? _selectedUserId;

  String get myId => supabase.auth.currentUser!.id;

  static const mapboxToken =
      'pk.eyJ1IjoiZmx1dHRlci1sb2ciLCJhIjoiY21reTlldGphMDNqdTNkcjBub3E1Ym5hdCJ9.lJOm6O5jAdmnLlyvLZ7afg';

  String get tileUrl =>
      'https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/256/{z}/{x}/{y}?access_token=$mapboxToken';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await Permission.location.request();
    await _loadProfile();
    await _refreshLocation();
    _startFriendsPolling();
  }

  // -------- PROFILE --------
  Future<void> _loadProfile() async {
    final me = await supabase
        .from('User')
        .select('avatar_url, username')
        .eq('user_id', myId)
        .maybeSingle();

    if (!mounted) return;
    setState(() {
      avatarUrl = me?['avatar_url'];
      username = me?['username'];
    });
  }

  // -------- LOCATION --------
  Future<void> _refreshLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) return;

    LocationPermission p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) {
      p = await Geolocator.requestPermission();
    }
    if (p == LocationPermission.denied || p == LocationPermission.deniedForever)
      return;

    final pos = await Geolocator.getCurrentPosition();
    await _update(pos, moveMap: true);
  }

  Future<void> _update(Position p, {bool moveMap = false}) async {
    final ll = LatLng(p.latitude, p.longitude);
    if (!mounted) return;

    setState(() => currentLocation = ll);

    if (moveMap) {
      _mapController.move(ll, _zoom);
    }

    await supabase.from('user_location').upsert({
      'user_id': myId,
      'latitude': p.latitude,
      'longitude': p.longitude,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id');
  }

  // -------- FRIENDS --------
  void _startFriendsPolling() {
    _fetchFriends();
    _friendsTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _fetchFriends(),
    );
  }

  Future<void> _fetchFriends() async {
    try {
      final a = await supabase
          .from('friendship')
          .select('receiver_id')
          .eq('sender_id', myId)
          .eq('status', 'accepted');

      final b = await supabase
          .from('friendship')
          .select('sender_id')
          .eq('receiver_id', myId)
          .eq('status', 'accepted');

      final ids = <String>{
        ...a.map((e) => e['receiver_id'] as String),
        ...b.map((e) => e['sender_id'] as String),
      };

      if (ids.isEmpty) {
        if (mounted) setState(() => friendsLocations = []);
        return;
      }

      final locations = await supabase
          .from('user_location')
          .select('user_id, latitude, longitude')
          .inFilter('user_id', ids.toList());

      final users = await supabase
          .from('User')
          .select('user_id, avatar_url, username')
          .inFilter('user_id', ids.toList());

      final userMap = {
        for (final u in users)
          u['user_id']: {'avatar': u['avatar_url'], 'username': u['username']},
      };

      final merged = locations.map((e) {
        final u = userMap[e['user_id']];
        return {...e, 'avatar': u?['avatar'], 'username': u?['username']};
      }).toList();

      if (mounted) setState(() => friendsLocations = merged);
    } catch (e) {
      debugPrint('Friends fetch error: $e');
    }
  }

  // -------- SEARCH LOGIC --------
  List<Map<String, dynamic>> _friendSuggestions() {
    if (_searchQuery.trim().length < 3) return [];
    final q = _searchQuery.toLowerCase();

    return friendsLocations
        .where(
          (f) => (f['username'] ?? '').toString().toLowerCase().contains(q),
        )
        .toList()
      ..sort((a, b) => (a['username'] ?? '').compareTo(b['username'] ?? ''));
  }

  void _moveToFriend(Map<String, dynamic> friend) {
    final lat = friend['latitude'];
    final lng = friend['longitude'];
    if (lat == null || lng == null) return;

    _mapController.move(LatLng(lat, lng), _zoom);

    setState(() {
      _selectedUserId = friend['user_id'];
      _searchQuery = friend['username'] ?? '';
      _searchController.text = _searchQuery;
      _searchFocusNode.unfocus();
    });
  }

  // -------- UI HELPERS --------
  ImageProvider? _avatarProvider(String? url) {
    if (url == null || url.isEmpty) return null;
    return url.startsWith('http') ? NetworkImage(url) : AssetImage(url);
  }

  Widget _nameBubble(String name) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        name,
        style: const TextStyle(color: Colors.white, fontSize: 12),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // -------- MAP --------
  Widget _mapWidget() {
    final center = currentLocation ?? const LatLng(37.7749, -122.4194);

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: _zoom,
        onTap: (_, __) => setState(() {
          _selectedUserId = null;
          _searchFocusNode.unfocus();
        }),
      ),
      children: [
        TileLayer(urlTemplate: tileUrl, userAgentPackageName: 'geo.app'),
        MarkerLayer(
          markers: [
            // -------- YOU --------
            if (currentLocation != null)
              Marker(
                point: currentLocation!,
                width: 140, // 👈 IMPORTANT (same as your code)
                height: 70, // 👈 IMPORTANT
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedUserId = _selectedUserId == myId ? null : myId;
                    });
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_selectedUserId == myId)
                        _nameBubble(username ?? 'You'),
                      CircleAvatar(
                        radius: 14,
                        backgroundImage: _avatarProvider(avatarUrl),
                        child: avatarUrl == null
                            ? const Icon(Icons.person, size: 20)
                            : null,
                      ),
                    ],
                  ),
                ),
              ),

            // -------- FRIENDS --------
            ...friendsLocations
                .where((f) => f['latitude'] != null && f['longitude'] != null)
                .map((e) {
                  final lat = (e['latitude'] as num).toDouble();
                  final lng = (e['longitude'] as num).toDouble();

                  return Marker(
                    point: LatLng(lat, lng),
                    width: 140, // 👈 SAME AS ORIGINAL
                    height: 70, // 👈 SAME AS ORIGINAL
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedUserId = _selectedUserId == e['user_id']
                              ? null
                              : e['user_id'];
                        });
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_selectedUserId == e['user_id'])
                            _nameBubble(e['username'] ?? 'Friend'),
                          CircleAvatar(
                            radius: 14,
                            backgroundImage: _avatarProvider(e['avatar']),
                            child: e['avatar'] == null
                                ? const Icon(Icons.person, size: 16)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  );
                })
                .toList(),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _friendsTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // -------- BUILD --------
  @override
  Widget build(BuildContext context) {
    final suggestions = _friendSuggestions();

    return Stack(
      children: [
        _mapWidget(),

        // 🔍 Search bar
        Positioned(
          top: 10,
          left: 16,
          right: 60,
          child: Material(
            borderRadius: BorderRadius.lerp(
              BorderRadius.circular(32),
              BorderRadius.circular(16),
              0.5,
            ),
            elevation: 5,
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: (v) => setState(() => _searchQuery = v),
              onSubmitted: (_) {
                if (suggestions.isNotEmpty) {
                  _moveToFriend(suggestions.first);
                }
              },
              decoration: const InputDecoration(
                labelText: 'Search friends',
                prefixIcon: Icon(Icons.search),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
        ),

        // 📋 Suggestions
        if (suggestions.isNotEmpty && _searchFocusNode.hasFocus)
          Positioned(
            top: 72,
            left: 16,
            right: 60,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(16),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: suggestions.length,
                itemBuilder: (_, i) {
                  final f = suggestions[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: _avatarProvider(f['avatar']),
                    ),
                    title: Text(f['username'] ?? 'Friend'),
                    onTap: () => _moveToFriend(f),
                  );
                },
              ),
            ),
          ),

        Positioned(
          top: 16,
          right: 16,
          child: FloatingActionButton(
            mini: true,
            onPressed: _refreshLocation,
            child: const Icon(Icons.my_location),
          ),
        ),
      ],
    );
  }
}
