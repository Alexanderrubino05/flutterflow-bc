import '/flutter_flow/flutter_flow_util.dart';
import '/widgets/custom_drawer/custom_drawer_widget.dart';
import 'competetion_page_widget.dart' show CompetetionPageWidget;
import 'package:flutter/material.dart';

class CompetetionPageModel extends FlutterFlowModel<CompetetionPageWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  // Model for CustomDrawer component.
  late CustomDrawerModel customDrawerModel;

  /// Initialization and disposal methods.

  @override
  void initState(BuildContext context) {
    customDrawerModel = createModel(context, () => CustomDrawerModel());
  }

  @override
  void dispose() {
    unfocusNode.dispose();
    customDrawerModel.dispose();
  }

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
