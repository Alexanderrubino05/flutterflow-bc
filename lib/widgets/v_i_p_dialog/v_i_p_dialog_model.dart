import '/flutter_flow/flutter_flow_util.dart';
import 'v_i_p_dialog_widget.dart' show VIPDialogWidget;
import 'package:flutter/material.dart';

class VIPDialogModel extends FlutterFlowModel<VIPDialogWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  Color? colorPicked;

  /// Initialization and disposal methods.

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
