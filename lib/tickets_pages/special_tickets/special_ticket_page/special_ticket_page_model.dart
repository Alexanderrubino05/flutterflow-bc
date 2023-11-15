import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'special_ticket_page_widget.dart' show SpecialTicketPageWidget;
import 'package:flutter/material.dart';

class SpecialTicketPageModel extends FlutterFlowModel<SpecialTicketPageWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  // Stores action output result for [Backend Call - API (createPayment)] action in CustomButton widget.
  ApiCallResponse? apiResult7kp;

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
