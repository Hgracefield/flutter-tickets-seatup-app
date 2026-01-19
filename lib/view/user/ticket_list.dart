import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/model/post.dart';
import 'package:seatup_app/vm/post_notifier.dart';

class TicketList extends ConsumerStatefulWidget {
  const TicketList({super.key});

  @override
  ConsumerState<TicketList> createState() => _TicketListState();
}

class _TicketListState extends ConsumerState<TicketList> {
// === Property ===

  late TextEditingController searchController;
  late List<Post> postList;
  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    postList = [];
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '검색',
          style: TextStyle(
            color: Color(0xFF1E3A8A),
            fontWeight: FontWeight.w900,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1E3A8A)),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              _buildTextField(searchController, '공연을 검색해보세요'),
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: postList.isEmpty
                ? SizedBox.shrink()
                : ListView.builder(
                  itemCount: postList.length,
                  itemBuilder: (context, index) {
                    return Card(child: Text(postList[index].post_curtain_id.toString()));
                  },),
              ),
            ],
          ),
        ),
      ),
    );
  } // build

  // === Widgets ===

  Widget _buildTextField(TextEditingController controller, String msg) {
    return TextField(
      controller: searchController,
      keyboardType: TextInputType.emailAddress,
      onSubmitted: (value) async {
        // 검색
        search();
      },
      decoration: InputDecoration(
        hintText: msg,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        filled: true,
        prefixIcon: Icon(Icons.search, color: Colors.grey),
        fillColor: const Color(0xFFF8F8F8),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
    );
  } // _buildTextField

  // === Functions ===

  Future search() async {
    String keyword = searchController.text.trim();
    if (keyword.isNotEmpty) {
      postList = await ref.read(postNotifierProvider.notifier).searchPost(keyword);
      setState(() {
        
      });
    }
  }
}