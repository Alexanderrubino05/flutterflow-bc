import '/flutter_flow/flutter_flow_util.dart';
import 'on_boarding_birthday_widget.dart' show OnBoardingBirthdayWidget;
import 'package:flutter/material.dart';

class OnBoardingBirthdayModel
    extends FlutterFlowModel<OnBoardingBirthdayWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  DateTime? datePicked;

  /// Initialization and disposal methods.

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
  }

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
