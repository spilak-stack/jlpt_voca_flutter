import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'package:jlpt241218/json_control.dart';
import 'package:auto_size_text/auto_size_text.dart';

enum SortCriteria { Japanese, Bookmark, Random }

enum SortOrder { Ascending, Descending }

class WordListPage extends StatefulWidget {
  final int n;

  const WordListPage({super.key, required this.n});

  @override
  State<WordListPage> createState() => _WordListPageState();
}

class _WordListPageState extends State<WordListPage> {
  List<Map<String, dynamic>> _wordData = [];
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();
  late List<bool> _showFurigana;
  late List<bool> _showMeaning;
  bool _showAllFurigana = true;
  bool _showAllMeaning = true;
  SortCriteria _selectedSortCriteria = SortCriteria.Japanese;
  SortOrder _selectedSortOrder = SortOrder.Ascending;

  // 검색 관련 변수 추가
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadWordData();
  }

  Future<void> _loadWordData() async {
    _wordData = await readWordData(widget.n);
    _sortWordData();
    _showFurigana = List.filled(_wordData.length, true);
    _showMeaning = List.filled(_wordData.length, true);
    setState(() {});
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _toggleFurigana(int index) {
    setState(() {
      _showFurigana[index] = !_showFurigana[index];
    });
  }

  void _toggleMeaning(int index) {
    setState(() {
      _showMeaning[index] = !_showMeaning[index];
    });
  }

  void _toggleBookmark(int index) {
    setState(() {
      _wordData[index]['Bookmark'] = _wordData[index]['Bookmark'] == 1 ? 0 : 1;
      writeWordData(widget.n, _wordData);
      // _loadWordData(); // 이 부분을 제거합니다.
    });
  }

  void _toggleAllFurigana() {
    setState(() {
      _showAllFurigana = !_showAllFurigana;
      _showFurigana = List.filled(_wordData.length, _showAllFurigana);
    });
  }

  void _toggleAllMeaning() {
    setState(() {
      _showAllMeaning = !_showAllMeaning;
      _showMeaning = List.filled(_wordData.length, _showAllMeaning);
    });
  }

  void _sortWordData() {
    switch (_selectedSortCriteria) {
      case SortCriteria.Japanese:
        _wordData.sort((a, b) => a['Furigana'].compareTo(b['Furigana']));
        break;
      case SortCriteria.Bookmark:
        _wordData.sort((a, b) => b['Bookmark'].compareTo(a['Bookmark']));
        break;
      case SortCriteria.Random:
        _wordData.shuffle();
        break;
    }
    if (_selectedSortOrder == SortOrder.Descending) {
      _wordData = _wordData.reversed.toList();
    }
  }

  void _toggleSortCriteria() {
    setState(() {
      _selectedSortCriteria = _selectedSortCriteria == SortCriteria.Japanese
          ? SortCriteria.Bookmark
          : _selectedSortCriteria == SortCriteria.Bookmark
              ? SortCriteria.Random
              : SortCriteria.Japanese;
      _sortWordData();
    });
  }

  void _toggleSortOrder() {
    setState(() {
      _selectedSortOrder = _selectedSortOrder == SortOrder.Ascending
          ? SortOrder.Descending
          : SortOrder.Ascending;
      _sortWordData();
    });
  }

  // 검색 상태 토글 함수
  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        FocusScope.of(context).requestFocus(_searchFocusNode);
        _searchText = "";
        _searchController.clear();
      }
    });
  }

  // 검색 기능 수행 함수
  void _performSearch() {
    setState(() {
      _searchText = _searchController.text;
    });
  }

  // 검색창 UI 구성 함수
  PreferredSizeWidget _buildSearchField() {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        cursorColor: Colors.white,
        decoration: InputDecoration(
          hintText: "단어, 후리가나, 뜻으로 검색",
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.white70),
        ),
        style: TextStyle(color: Colors.white, fontSize: 16.0),
        onChanged: (text) {
          _performSearch(); // 입력 변경 시 검색 수행
        },
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new),
        onPressed: () {
          _toggleSearch(); // 검색 모드 종료
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = AppTheme.of(context);

    // 검색 결과 필터링
    final filteredWordData = _searchText.isEmpty
        ? _wordData
        : _wordData.where((word) {
            final lowerSearchText = _searchText.toLowerCase();
            return word['Word'].toLowerCase().contains(lowerSearchText) ||
                word['Furigana'].toLowerCase().contains(lowerSearchText) ||
                word['Meaning'].toLowerCase().contains(lowerSearchText);
          }).toList();

    return Scaffold(
      appBar: _isSearching
          ? _buildSearchField()
          : AppBar(
              centerTitle: true,
              title: Text("N${widget.n}"),
              actions: [
                IconButton(
                  icon: Icon(Theme.of(context).brightness == Brightness.light
                      ? Icons.dark_mode_outlined
                      : Icons.light_mode_outlined),
                  onPressed: appTheme.toggleTheme,
                ),
              ],
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () => Navigator.pop(context),
              ),
            ),
      body: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.08,
            margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            child: Card(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  // 버튼을 왼쪽 정렬로 변경
                  children: [
                    SizedBox(width: 20),
                    // 정렬 기준 버튼
                    IconButton(
                      onPressed: () => _toggleSortCriteria(),
                      icon: Icon(
                        _selectedSortCriteria == SortCriteria.Japanese
                            ? Icons.sort_by_alpha
                            : _selectedSortCriteria == SortCriteria.Bookmark
                                ? Icons.star
                                : Icons.shuffle,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _toggleSortOrder(),
                      icon: Icon(_selectedSortOrder == SortOrder.Ascending
                          ? Icons.arrow_upward
                          : Icons.arrow_downward),
                    ),

                    Spacer(),
                    // 후리가나, 뜻 숨기기/보이기 버튼
                    ElevatedButton(
                      onPressed: _toggleAllFurigana,
                      style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size(
                              MediaQuery.of(context).size.width * 0.2,
                              MediaQuery.of(context).size.height * 0.08),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero)),
                      child: Text(_showAllFurigana ? '후리가나 숨기기' : '후리가나 보이기',
                          style: TextStyle(
                              fontFamily: 'KO',
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Color(0xFF000000)
                                  : Color(0xFFFFFFFF))),
                    ),
                    ElevatedButton(
                      onPressed: _toggleAllMeaning,
                      style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size(
                              MediaQuery.of(context).size.width * 0.2,
                              MediaQuery.of(context).size.height * 0.08),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero)),
                      child: Text(_showAllMeaning ? '뜻 숨기기' : '뜻 보이기',
                          style: TextStyle(
                              fontFamily: 'KO',
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Color(0xFF000000)
                                  : Color(0xFFFFFFFF))),
                    )
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: filteredWordData.isEmpty
                  ? const CircularProgressIndicator()
                  : ListView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.vertical,
                      itemCount: filteredWordData.length, // 필터링된 데이터 길이 사용
                      itemBuilder: (context, index) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.08,
                          margin: const EdgeInsets.all(0),
                          child: Card(
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  AutoSizeText(filteredWordData[index]['Word'],
                                      maxLines: 1,
                                      style: const TextStyle(
                                          fontSize: 40,
                                          // fontWeight: FontWeight.bold,
                                          fontFamily: 'JP')),
                                  Row(children: [
                                    IconButton(
                                        onPressed: () => _toggleBookmark(index),
                                        icon: Icon(filteredWordData[index]
                                                    ['Bookmark'] ==
                                                1
                                            ? Icons.star
                                            : Icons.star_border)),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () => _toggleFurigana(index),
                                      style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          fixedSize: Size(
                                              MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.2,
                                              100),
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.zero)),
                                      child: Visibility(
                                        maintainAnimation: true,
                                        maintainState: true,
                                        maintainSize: true,
                                        visible: _showFurigana[index],
                                        child: AutoSizeText(
                                            filteredWordData[index]['Furigana'],
                                            maxLines: 1,
                                            style: const TextStyle(
                                                fontSize: 25,
                                                fontFamily: 'JP')),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ElevatedButton(
                                      onPressed: () => _toggleMeaning(index),
                                      style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          fixedSize: Size(
                                              MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.2,
                                              100),
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.zero)),
                                      child: Visibility(
                                        maintainAnimation: true,
                                        maintainState: true,
                                        maintainSize: true,
                                        visible: _showMeaning[index],
                                        child: AutoSizeText(
                                            filteredWordData[index]['Meaning'],
                                            maxLines: 1,
                                            style: const TextStyle(
                                                fontSize: 25,
                                                fontFamily: 'KO')),
                                      ),
                                    )
                                  ])
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      // 플로팅 버튼 스택 추가
      floatingActionButton: Stack(
        children: [
          // 검색 버튼
          Positioned(
            bottom: 80,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'searchButton',
              onPressed: _toggleSearch,
              child: Icon(Icons.search),
            ),
          ),
          // 위로 가기 버튼
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'scrollToTopButton',
              onPressed: _scrollToTop,
              child: Icon(Icons.arrow_upward),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose(); // 검색 컨트롤러 해제
    _searchFocusNode.dispose();
    super.dispose();
  }
}
