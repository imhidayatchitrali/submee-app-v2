import 'package:flutter/material.dart';
import 'package:submee/widgets/banners/error_banner.dart';
import 'package:submee/widgets/banners/success_banner.dart';

import '../widgets/banners/confirmation_banner.dart';

void showConfirmationBanner(
  BuildContext context, {
  required String title,
  required String body,
  required String buttonText,
  required VoidCallback onPressed,
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) => ConfirmationBanner(
      title: title,
      body: body,
      buttonText: buttonText,
      onPressed: onPressed,
    ),
  );
}

void showSuccessBanner(
  BuildContext context, {
  required String title,
  required String body,
  required String buttonText,
  VoidCallback? onPressed,
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) => SuccessBanner(
      title: title,
      body: body,
      buttonText: buttonText,
      onPressed: onPressed,
    ),
  );
}

void showFailedBanner(
  BuildContext context, {
  required String title,
  required String body,
  required String buttonText,
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) => ErrorBanner(
      title: title,
      body: body,
      buttonText: buttonText,
    ),
  );
}
