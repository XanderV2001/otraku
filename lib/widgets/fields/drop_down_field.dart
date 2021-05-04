import 'package:flutter/material.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/widgets/fields/input_field_structure.dart';

class DropDownField<T> extends StatefulWidget {
  final String title;
  final T? initialValue;
  final Map<String, T> items;
  final Function(T) onChanged;
  final String hint;

  DropDownField({
    required this.title,
    required this.initialValue,
    required this.items,
    required this.onChanged,
    this.hint = 'Choose',
  });

  @override
  _DropDownFieldState<T> createState() => _DropDownFieldState<T>();
}

class _DropDownFieldState<T> extends State<DropDownField<T>> {
  T? value;

  @override
  Widget build(BuildContext context) {
    final items = <DropdownMenuItem<T>>[];
    for (final key in widget.items.keys)
      items.add(DropdownMenuItem(
        value: widget.items[key],
        child: Text(
          key,
          style: widget.items[key] != value
              ? Theme.of(context).textTheme.bodyText2
              : Theme.of(context).textTheme.bodyText1,
        ),
      ));

    return InputFieldStructure(
      title: widget.title,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: Config.BORDER_RADIUS,
        ),
        child: Theme(
          data: Theme.of(context)
              .copyWith(highlightColor: Theme.of(context).accentColor),
          child: DropdownButton<T>(
            value: value,
            items: items,
            onChanged: (val) {
              setState(() => value = val!);
              widget.onChanged(val!);
            },
            hint: Text(
              widget.hint,
              style: Theme.of(context).textTheme.subtitle1,
            ),
            iconEnabledColor: Theme.of(context).disabledColor,
            dropdownColor: Theme.of(context).primaryColor,
            underline: const SizedBox(),
            isExpanded: true,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    value = widget.initialValue;
  }
}
