import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/request_manager.dart';

import 'users_admin_widget.dart' show UsersAdminWidget;
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

class UsersAdminModel extends FlutterFlowModel<UsersAdminWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  // Algolia Search Results from action on Button
  List<UsersRecord>? algoliaSearchResults = [];
  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;

  // Stores action output result for [Firestore Query - Query a collection] action in Icon widget.
  UsersRecord? fanklubUser;

  /// Query cache managers for this widget.

  final _usersManager = FutureRequestManager<List<UsersRecord>>();
  Future<List<UsersRecord>> users({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<List<UsersRecord>> Function() requestFn,
  }) =>
      _usersManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearUsersCache() => _usersManager.clear();
  void clearUsersCacheKey(String? uniqueKey) =>
      _usersManager.clearRequest(uniqueKey);

  /// Initialization and disposal methods.

  @override
  void initState(BuildContext context) {
    dataTableShowLogs = false; // Disables noisy DataTable2 debug statements.
    dataTableShowLogs = false; // Disables noisy DataTable2 debug statements.
    dataTableShowLogs = false; // Disables noisy DataTable2 debug statements.
    dataTableShowLogs = false; // Disables noisy DataTable2 debug statements.
  }

  @override
  void dispose() {
    unfocusNode.dispose();
    textFieldFocusNode?.dispose();
    textController?.dispose();

    tabBarController?.dispose();

    /// Dispose query cache managers for this widget.

    clearUsersCache();
  }

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
