
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../utilis/colorcode.dart';

class CustomTypeAheadFormField<T> extends StatefulWidget {
  final TextEditingController controller;
  final List<T> suggestions;
  final void Function(T) onSuggestionSelected;
  final void Function(T)? onTap;
  final void Function(T)? onItemValueChanged;
  final String Function(T) itemBuilder;
  final String hintText;
  final Color? borderColor;
  final double? borderWidth;
  final String? initialValueId; // New parameter for initial value
  final double? fontSize;

  CustomTypeAheadFormField({
    required this.controller,
    required this.suggestions,
    required this.onSuggestionSelected,
    this.onTap,
    this.onItemValueChanged,
    required this.itemBuilder,
    required this.hintText,
    this.borderColor,
    this.borderWidth,
    this.initialValueId,
    this.fontSize,
  });

  @override
  _CustomTypeAheadFormFieldState<T> createState() => _CustomTypeAheadFormFieldState<T>();
}

class _CustomTypeAheadFormFieldState<T> extends State<CustomTypeAheadFormField<T>> {
  GlobalKey _widgetKey = GlobalKey();
  SuggestionsBoxController _suggestionsBoxController = SuggestionsBoxController();
  T? _selectedValue;

  @override
  void initState() {
    super.initState();
    // Find the initial suggestion based on initialValueId
    for (var suggestion in widget.suggestions) {
      if (widget.itemBuilder(suggestion) == widget.initialValueId) {
        _selectedValue = suggestion;
        break;
      }
    }
    // If no initial suggestion is found, default to the first suggestion
    _selectedValue ??= widget.suggestions.isNotEmpty ? widget.suggestions.first : null;
  }



  @override
  Widget build(BuildContext context) {
    double defaultFontSize = widget.fontSize ?? 14.0;

    Brightness brightness = Theme.of(context).brightness;
    Color borderColor = Colors.transparent;
    double borderWidth = widget.borderWidth ?? 0.0;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_widgetKey.currentContext != null) {
            final RenderBox renderBox = _widgetKey.currentContext!.findRenderObject() as RenderBox;
            final tapPosition = renderBox.globalToLocal(TapDownDetails().globalPosition);
            if (!renderBox.paintBounds.contains(tapPosition)) {
              _suggestionsBoxController.close();
            }
          }
        },
        child: Container(
          key: _widgetKey,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(

            color: ColorCode.textboxanddropdownbackcolor,
            borderRadius: BorderRadius.all(Radius.circular(10)),
            border: Border.all(
              color: borderColor,
              width: borderWidth,
            ),
          ),

          child: Row(
            children: [
              Expanded(
                child: TypeAheadFormField<T>(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: widget.controller,
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: ColorCode.appcolor),
                    ),
                    style: TextStyle(color: ColorCode.btncolor, fontSize: defaultFontSize),
                    onEditingComplete: () {
                      if (widget.suggestions.isNotEmpty) {
                        List<T> sortedSuggestions = widget.suggestions
                            .where((option) => widget.itemBuilder(option).toLowerCase().contains(widget.controller.text.toLowerCase()))
                            .toList()
                          ..sort((a, b) => _comparePatterns(widget.itemBuilder(a), widget.itemBuilder(b), widget.controller.text));
                        if (sortedSuggestions.isNotEmpty) {
                          T lastSortedSuggestion = sortedSuggestions.last;
                          widget.onSuggestionSelected(lastSortedSuggestion);
                          widget.controller.text = widget.itemBuilder(lastSortedSuggestion);
                        }
                      }
                    },
                  ),
                  hideOnEmpty: true,
                  suggestionsCallback: (pattern) {
                    if (widget.suggestions.any((option) => widget.itemBuilder(option) == widget.controller.text)) {
                      return [];
                    }
                    List<T> filteredSuggestions = widget.suggestions
                        .where((option) => widget.itemBuilder(option).toLowerCase().contains(pattern.toLowerCase()))
                        .toList()
                      ..sort((a, b) => _comparePatterns(widget.itemBuilder(a), widget.itemBuilder(b), pattern));
                    return filteredSuggestions;
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(
                        widget.itemBuilder(suggestion),
                        style: TextStyle(color: Colors.black, fontSize: defaultFontSize),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedValue = suggestion; // Update selected value
                        });
                        widget.onSuggestionSelected(suggestion);
                        if (widget.onTap != null) {
                          widget.onTap!(suggestion);
                        }
                        if (widget.onItemValueChanged != null) {
                          widget.onItemValueChanged!(suggestion);
                        }
                      },
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    setState(() {
                      _selectedValue = suggestion; // Update selected value
                    });
                    widget.onSuggestionSelected(suggestion);
                    if (widget.onTap != null) {
                      widget.onTap!(suggestion);
                    }
                    if (widget.onItemValueChanged != null) {
                      widget.onItemValueChanged!(suggestion);
                    }
                  },
                  suggestionsBoxController: _suggestionsBoxController,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _suggestionsBoxController.toggle();
                  });
                },
                child: Icon(Icons.arrow_drop_down),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _comparePatterns(String a, String b, String pattern) {
    int indexA = a.toLowerCase().indexOf(pattern.toLowerCase());
    int indexB = b.toLowerCase().indexOf(pattern.toLowerCase());
    return indexA - indexB;
  }
}
