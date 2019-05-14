import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

class CustomCircleAvatar extends StatelessWidget {
  final String imageUrl;
  final String name;
  final double radius;
  final String initial;

  CustomCircleAvatar({this.imageUrl, this.name, this.radius})
      : initial = isBlank(name) ? "A" : name.substring(0, 1).toUpperCase();

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    Widget initialNameAvatar() => CircleAvatar(
          backgroundColor: _theme.primaryColor,
          child: Text(
            initial,
            style: _theme.textTheme.subhead.copyWith(color: Colors.white),
          ),
          radius: this.radius,
        );

    Widget getImageViaUrl() {
      return CircleAvatar(
        backgroundColor: Colors.transparent,
        backgroundImage: NetworkImage(imageUrl),
        radius: this.radius,
      );
    }

    return isBlank(imageUrl) ? initialNameAvatar() : getImageViaUrl();
  }
}
