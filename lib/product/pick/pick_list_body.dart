import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quickpick/localization/locale_text.dart';
import 'package:quickpick/localization/locales.dart';
import 'package:quickpick/product/base/page_body.dart';
import 'package:quickpick/product/pick/pick_list_empty.dart';
import 'package:quickpick/product/pick/pick_page.dart';
import 'package:quickpick/request/request.dart';
import 'package:skeletonizer/skeletonizer.dart';

class PickListBody extends ProductPageBody {
  final GlobalKey<_PickListBodyContentState> _key =
      GlobalKey<_PickListBodyContentState>();

  PickListBody({super.key})
      : super(
          name: "product.pick.list.label",
          unselectedIcon: CupertinoIcons.text_bubble,
          selectedIcon: CupertinoIcons.text_bubble_fill,
        );

  @override
  Widget content(BuildContext context) {
    return PickListBodyContent(key: _key);
  }

  @override
  Future<int> notifications(BuildContext context) async {
    final response = await Request.get(url: "/pick/list/").send();
    if (response == null) return 0;

    final body = jsonDecode(response.body);
    if (body["success"] == true) {
      final picks = List<Map<String, dynamic>>.from(body["picks"] ?? []);
      final now = DateTime.now().millisecondsSinceEpoch;
      return picks.where((p) => (p["expires_at"] as int) > now).length;
    }
    return 0;
  }
}

class PickListBodyContent extends StatefulWidget {
  const PickListBodyContent({super.key});

  @override
  State<PickListBodyContent> createState() => _PickListBodyContentState();
}

class _PickListBodyContentState extends State<PickListBodyContent> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _picks = [];
  bool _isLoading = true;
  Timer? _timer;

  static const int _skeletonCount = 6;

  static final List<Map<String, dynamic>> _skeletonPicks = List.generate(
    _skeletonCount,
    (i) => {
      "id": "skeleton_$i",
      "creator_name": "Loading Name",
      "type": "Loading type",
      "expires_at":
          DateTime.now().add(const Duration(hours: 2)).millisecondsSinceEpoch,
    },
  );

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    _loadPicks();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadPicks() async {
    final response = await Request.get(url: "/pick/list/").send();
    if (response == null) return;

    final body = jsonDecode(response.body);
    if (body["success"] == true) {
      final picks = List<Map<String, dynamic>>.from(body["picks"]);
      picks.sort(
          (a, b) => (b["created_at"] as int).compareTo(a["created_at"] as int));
      setState(() {
        _picks = picks;
        _isLoading = false;
      });
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  void scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  List<Map<String, dynamic>> get _filteredPicks {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return _picks;
    return _picks
        .where((p) =>
            (p["type"] as String).toLowerCase().contains(query) ||
            (p["creator_name"] as String).toLowerCase().contains(query))
        .toList();
  }

  String _formatExpiry(int expiresAt) {
    final expiry = DateTime.fromMillisecondsSinceEpoch(expiresAt);
    final diff = expiry.difference(DateTime.now());

    if (diff.inHours >= 1) {
      final h = diff.inHours;
      final m = diff.inMinutes % 60;
      return "${h}h ${m}m";
    } else if (diff.inMinutes >= 1) {
      final m = diff.inMinutes;
      final s = diff.inSeconds % 60;
      return "${m}m ${s}s";
    } else {
      return "${diff.inSeconds}s";
    }
  }

  Color _expiryColor(int expiresAt) {
    final diff = DateTime.fromMillisecondsSinceEpoch(expiresAt)
        .difference(DateTime.now());
    if (diff.inMinutes < 1) return Colors.red;
    if (diff.inHours < 1) return Colors.orange;
    return Colors.grey;
  }

  Widget _buildList(List<Map<String, dynamic>> picks, {bool skeleton = false}) {
    return ListView.builder(
      controller: skeleton ? null : _scrollController,
      itemCount: picks.length,
      itemBuilder: (context, index) {
        final pick = picks[index];
        final expiresAt = pick["expires_at"] as int;
        return ListTile(
          leading: skeleton
              ? const Bone.circle(size: 52)
              : const CircleAvatar(
                  radius: 26,
                  foregroundColor: Colors.white,
                  child: Icon(CupertinoIcons.photo, size: 28),
                ),
          title: Text(
            pick["creator_name"] ?? "",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            pick["type"] ?? "",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          trailing: Text(
            _formatExpiry(expiresAt),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _expiryColor(expiresAt),
            ),
          ),
          onTap: skeleton
              ? null
              : () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PickPage(pickId: pick["id"] as String),
                    ),
                  );
                  setState(() {
                    _picks.removeWhere((p) => p["id"] == pick["id"]);
                  });
                },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Skeletonizer(
              child: CupertinoSearchTextField(
                placeholder:
                    Locales.string(context, "product.pick.list.search"),
              ),
            ),
          ),
          Expanded(
            child: Skeletonizer(
              child: _buildList(_skeletonPicks, skeleton: true),
            ),
          ),
        ],
      );
    }

    if (_picks.isEmpty) {
      return const PickListEmptyContent();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: CupertinoSearchTextField(
            controller: _searchController,
            placeholder: Locales.string(context, "product.pick.list.search"),
            onChanged: (_) => setState(() {}),
          ),
        ),
        Expanded(
          child: _filteredPicks.isEmpty
              ? const Center(
                  child: LocaleText(
                    "product.pick.list.no.results",
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : _buildList(_filteredPicks),
        ),
      ],
    );
  }
}
