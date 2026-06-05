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
    final response = await Request.get(url: "/pick/list/").send(context);
    if (response == null) return;

    final body = jsonDecode(response.body);
    if (body["success"] == true) {
      final picks = List<Map<String, dynamic>>.from(body["picks"]);
      picks.sort((a, b) =>
          (b["created_at"] as int).compareTo(a["created_at"] as int));
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

    if (diff.isNegative) return "Abgelaufen";

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
    final diff =
    DateTime.fromMillisecondsSinceEpoch(expiresAt).difference(DateTime.now());
    if (diff.isNegative) return Colors.grey;
    if (diff.inMinutes < 1) return Colors.red;
    if (diff.inHours < 1) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CupertinoActivityIndicator());
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
              : ListView.builder(
            controller: _scrollController,
            itemCount: _filteredPicks.length,
            itemBuilder: (context, index) {
              final pick = _filteredPicks[index];
              final expiresAt = pick["expires_at"] as int;
              return ListTile(
                leading: const CircleAvatar(
                  foregroundColor: Colors.white,
                  child: Icon(CupertinoIcons.text_bubble),
                ),
                title: Text(pick["creator_name"] ?? ""),
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
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PickPage(
                      pickId: pick["id"] as String,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}