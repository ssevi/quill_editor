import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

void main() {
  runApp(QuillHtmlEditorApp());
}

class QuillHtmlEditorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quill HTML Editor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: QuillHtmlEditorPage(),
    );
  }
}

class QuillHtmlEditorPage extends StatefulWidget {
  @override
  _QuillHtmlEditorPageState createState() => _QuillHtmlEditorPageState();
}

class _QuillHtmlEditorPageState extends State<QuillHtmlEditorPage> {
  late quill.QuillController _controller;

  @override
  void initState() {
    super.initState();
    _controller = quill.QuillController.basic();
    _controller.addListener(() {
      setState(() {}); // Update HTML display when content changes
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getHtmlFromQuill() {
    final delta = _controller.document.toDelta().toJson();
    String html = '';
    for (var op in delta) {
      if (op['insert'] != null) {
        String text = op['insert'];
        Map<String, dynamic>? attributes = op['attributes'];

        if (attributes != null) {
          if (attributes.containsKey('bold')) {
            text = '<strong>$text</strong>';
          }
          if (attributes.containsKey('italic')) {
            text = '<em>$text</em>';
          }
          if (attributes.containsKey('underline')) {
            text = '<u>$text</u>';
          }
          if (attributes.containsKey('strike')) {
            text = '<s>$text</s>';
          }
          if (attributes.containsKey('link')) {
            String link = attributes['link'];
            text = '<a href="$link">$text</a>';
          }
          // Add more attribute conversions as needed
        }

        html += text;
      }

      if (op['insert'] == '\n') {
        html += '<br>';
      }
    }
    return html;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quill HTML Editor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Quill Toolbar
            quill.QuillToolbar.basic(
              controller: _controller,
              showAlignmentButtons: true,
              showLink: true,
              showStrikeThrough: true,
              showUnderLineButton: true,
              showInlineCode: false,
              showHeaderStyle: true,
              // Customize toolbar buttons as needed
            ),

            SizedBox(height: 10),

            // Quill Editor
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: quill.QuillEditor(
                  controller: _controller,
                  readOnly: false, // Set to true to make it read-only
                  scrollController: ScrollController(),
                  scrollable: true,
                  focusNode: FocusNode(),
                  autoFocus: false,
                  expands: false,
                  padding: EdgeInsets.all(10),
                ),
              ),
            ),

            SizedBox(height: 20),

            // HTML Display Box
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    _getHtmlFromQuill(),
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {}); // Refresh to update HTML display
        },
        child: Icon(Icons.refresh),
      ),
    );
  }
}
