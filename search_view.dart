import 'dart:math';
import 'package:flutter/material.dart';

// Stateful widget to implement search with animation
class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView>
    with SingleTickerProviderStateMixin {
  // AnimationController to control animations
  late AnimationController _animationController;

  // Animations for the current and next search text
  late Animation<Offset> _offsetAnimationCurrent;
  late Animation<Offset> _offsetAnimationNext;

  // FocusNode to track focus state of the TextField
  var focusNode = FocusNode();

  // List of grocery items for search suggestions
  List<String> groceryItems = [
    'Milk',
    'Bread',
    'Eggs',
    'Rice',
    'Tomatoes',
    'Chicken',
    'Apples',
    'Bananas',
    'Tomatoes',
    'Onions',
    'Potatoes',
    'Carrots',
    'Yogurt',
    'Cooking Oil',
    'Flour',
    'Tea',
    'Coffee'
  ];

  // Random object to generate random numbers for item selection
  final Random _random = Random();

  // Current search text input and items displayed in the animation
  String _searchText = "";
  String _currentItem = '';
  String _nextItem = '';

  @override
  void initState() {
    super.initState();
    // Initializing first item to display
    _currentItem = groceryItems[0];

    // Initialize animations, listeners, and first animation cycle
    _initializeAnimations();
    _addAnimationListener();
    _startFirstAnimationCycleAfterDelay();
    _handleKeyboardFocusAndAnimation();
  }

  @override
  Widget build(BuildContext context) {
    // Building the main widget structure
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        title: const Text("Search Animation Like Blinkit"),
      ),
      backgroundColor: Colors.grey.shade100,
      body: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, top: 30),
        width: double.infinity,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 1,
              offset: const Offset(1, 1),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 15),
              child: Icon(
                Icons.search,
                color: Colors.grey,
                size: 24,
              ),
            ),
            Expanded(
                child: Stack(
              alignment: Alignment.centerLeft,
              children: [_buildTextField(), _buildAnimatedText()],
            )),
            const Padding(
              padding: EdgeInsets.only(right: 15),
              child: Icon(
                Icons.mic,
                color: Colors.grey,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget to build the text input field
  Widget _buildTextField() {
    return Container(
      alignment: Alignment.centerLeft,
      height: 70,
      child: TextField(
        controller: null,
        maxLines: 1,
        focusNode: focusNode,
        style: const TextStyle(
            color: Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.normal,
            height: 1.5),
        autofocus: false,
        onChanged: (value) {
          _searchText = value; // Updates the search text as the user types
        },
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          hintText: focusNode.hasFocus ? "Search \"$_nextItem\"" : "",
          // Show hint with next item when focused
          isDense: true,
          hintStyle: const TextStyle(
              color: Colors.grey, fontSize: 13, fontWeight: FontWeight.normal),
          filled: true,
          fillColor: Colors.transparent,
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent, width: 1),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent, width: 1),
          ),
        ),
      ),
    );
  }

  // Widget to build the animated search text display
  Widget _buildAnimatedText() {
    return !focusNode.hasFocus
        ? ClipRRect(
            child: Container(
              margin: const EdgeInsets.only(left: 11),
              alignment: Alignment.centerLeft,
              height: 69,
              child: Stack(
                children: [
                  AnimatedBuilder(
                    animation: _offsetAnimationCurrent,
                    builder: (context, child) {
                      return Transform.translate(
                          offset: _offsetAnimationCurrent.value,
                          child: Text(
                            "Search \"$_currentItem\"",
                            style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                                fontWeight: FontWeight.normal),
                          ));
                    },
                  ),
                  AnimatedBuilder(
                    animation: _offsetAnimationNext,
                    builder: (context, child) {
                      return Transform.translate(
                          offset: _offsetAnimationNext.value,
                          child: Text("Search \"$_nextItem\"",
                              style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                  fontWeight: FontWeight.normal)));
                    },
                  ),
                ],
              ),
            ),
          )
        : const Center(); // Show nothing if the text field is focused
  }

  // Add listener to animation controller to update items after animation completes
  void _addAnimationListener() {
    _animationController.addListener(() {
      if (_animationController.isCompleted) {
        Future.delayed(const Duration(milliseconds: 2500), () {
          int randomInt = _random.nextInt(groceryItems.length);
          _currentItem = _nextItem; // Update current item with next item
          _nextItem = groceryItems[randomInt]; // Randomly pick a new next item
          _animationController.forward(from: 0); // Restart animation
        });
      }
    });
  }

  // Initialize the animations with the required configurations
  void _initializeAnimations() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));

    _offsetAnimationCurrent =
        Tween<Offset>(begin: const Offset(0, 0), end: const Offset(0, -100))
            .animate(CurvedAnimation(
                parent: _animationController, curve: Curves.easeIn));

    _offsetAnimationNext =
        Tween<Offset>(begin: const Offset(0, 50), end: const Offset(0, 0))
            .animate(CurvedAnimation(
                parent: _animationController, curve: Curves.easeIn));
  }

  // Start the first animation cycle after a delay
  void _startFirstAnimationCycleAfterDelay() {
    Future.delayed(const Duration(milliseconds: 2500), () {
      int randomInt = _random.nextInt(groceryItems.length);
      _nextItem = groceryItems[randomInt]; // Pick random next item
      _animationController.forward(); // Start the animation
    });
  }

  // Handle keyboard focus and animation state (stop/start animation)
  void _handleKeyboardFocusAndAnimation() {
    focusNode.addListener(() {
      if (_searchText.isNotEmpty) {
        return; // Don't change animation if search text is not empty
      }
      setState(() {
        if (focusNode.hasFocus) {
          _animationController
              .stop(); // Stop animation when keyboard is focused
        } else {
          _animationController.forward(
              from: 0); // Restart animation when keyboard is unfocused
        }
      });
    });
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    _animationController.dispose();
    focusNode.dispose();
    super.dispose();
  }
}
