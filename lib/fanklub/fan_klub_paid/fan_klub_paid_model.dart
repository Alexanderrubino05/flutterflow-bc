import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/instant_timer.dart';
import 'fan_klub_paid_widget.dart' show FanKlubPaidWidget;
import 'package:flutter/material.dart';

class FanKlubPaidModel extends FlutterFlowModel<FanKlubPaidWidget> {
  ///  Local state fields for this page.

  int? loopValue = 0;

  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  InstantTimer? instantTimer;
  // Stores action output result for [Backend Call - API (fetchPayment)] action in FanKlubPaid widget.
  ApiCallResponse? autoApiResult;
  // Stores action output result for [Backend Call - API (capturePayment)] action in FanKlubPaid widget.
  ApiCallResponse? captureAmountAPI;
  // Stores action output result for [Backend Call - API (fetchPayment)] action in Button widget.
  ApiCallResponse? apiResultb3f;
  // Stores action output result for [Backend Call - API (capturePayment)] action in Button widget.
  ApiCallResponse? apiResultjnm;
  // Stores action output result for [Backend Call - API (cancelPayment)] action in Button widget.
  ApiCallResponse? apiResult1wa;

  /// Initialization and disposal methods.

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
    instantTimer?.cancel();
  }

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
