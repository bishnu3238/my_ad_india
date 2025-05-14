import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_ad/features/home/core/home_navigator.dart';
import 'package:my_ad/features/home/shell/home_screen/core/home_provider.dart';
import 'package:pack/extensions/extensions.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:pack/services/service.dart';
import 'package:provider/provider.dart';

class HomeSearchBar extends StatefulWidget {
  const HomeSearchBar({super.key});

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initSpeech());
    // _initSpeech();
  }

  /// Initialize speech recognition functionality
  void _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: _onSpeechStatus,
      onError: (error) => _onSpeechError(error),
    );
    if (!available) {
      debugPrint("Speech recognition not available");
    }
  }

  /// Handle speech recognition status changes
  void _onSpeechStatus(String status) {
    debugPrint("Speech status: $status");
    if (status == 'notListening') {
      setState(() {
        _isListening = false;
      });

      // If we have text and stopped listening, navigate to search page
      if (_searchText.isNotEmpty) {
        _navigateToSearch(_searchText);
      }
    }
  }

  /// Handle speech recognition errors
  void _onSpeechError(dynamic error) {
    debugPrint("Speech error: $error");
    setState(() {
      _isListening = false;
    });

    NotifyService.googleFilesStyle(
      context: context,
      message: 'Could not recognize speech',
      duration: 2.seconds,
      color: Theme.of(context).colorScheme.errorContainer,
    );
  }

  /// Start or stop listening
  void _toggleListening() async {
    if (_isListening) {
      _speech.stop();
      setState(() {
        _isListening = false;
      });
    } else {
      setState(() {
        _isListening = true;
        _searchText = '';
      });

      await _speech.listen(
        onResult: (result) {
          setState(() {
            _searchText = result.recognizedWords;
            _searchController.text = _searchText;
          });
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        localeId: 'en_US',
        listenMode: stt.ListenMode.confirmation,
      );

      NotifyService.googleFilesStyle(
        context: context,
        message: 'Listening...',
        duration: 2.seconds,
      );
    }
  }

  /// Navigate to search page with query
  void _navigateToSearch([String? query]) {
    // Get the search provider
    final homeProvider = context.read<HomeScreenProvider>();

    // Update the search query if provided
    if (query != null && query.isNotEmpty) {
      homeProvider.setSearchQuery(query);
    }

    // Navigate to search page
    context.push(HomeRoute.search);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: context.colorScheme.onSurface.withOpacity(0.10),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade100.withOpacity(0.10),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 8),
            Icon(Icons.search, color: context.colorScheme.primary, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search for services, e.g. "Plumber, Tutor, Mechanic"',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onTap: () {
                  context.push(HomeRoute.search);
                },
                readOnly: true,
              ),
            ),
            IconButton(
              icon: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                color: _isListening ? Colors.red : context.colorScheme.primary,
              ),
              onPressed: _toggleListening,
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
