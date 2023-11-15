import '/auth/firebase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/instant_timer.dart';
import '/widgets/payment_completed_dialog/payment_completed_dialog_widget.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/random_data_util.dart' as random_data;
import 'package:aligned_dialog/aligned_dialog.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'have_paid_page_model.dart';
export 'have_paid_page_model.dart';

class HavePaidPageWidget extends StatefulWidget {
  const HavePaidPageWidget({
    super.key,
    this.amount,
    this.homeTeam,
    this.awayTeam,
    this.address,
    this.addressName,
    this.description,
    this.start,
    this.amountOfTickets,
  });

  final int? amount;
  final int? homeTeam;
  final int? awayTeam;
  final LatLng? address;
  final String? addressName;
  final String? description;
  final DateTime? start;
  final int? amountOfTickets;

  @override
  _HavePaidPageWidgetState createState() => _HavePaidPageWidgetState();
}

class _HavePaidPageWidgetState extends State<HavePaidPageWidget> {
  late HavePaidPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HavePaidPageModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.createPayment = await CreatePaymentCall.call(
        amount: widget.amount,
        description:
            'Køb ${widget.amountOfTickets?.toString()} billet(ter)  til ${FFAppState().teams[widget.homeTeam!].name} vs ${FFAppState().teams[widget.awayTeam!].name}',
        referenceString: random_data.randomString(
          6,
          8,
          true,
          false,
          false,
        ),
        idempotencyKey: functions.getRandomGUID(),
        redirectPath: ' bccopenhagen://bccopenhagen.com/HavePaidPage',
      );
      if ((_model.createPayment?.succeeded ?? true)) {
        await launchURL(getJsonField(
          (_model.createPayment?.jsonBody ?? ''),
          r'''$["mobilePayAppRedirectUri"]''',
        ).toString().toString());
        _model.instantTimer = InstantTimer.periodic(
          duration: const Duration(milliseconds: 3000),
          callback: (timer) async {
            _model.autoApiResult = await FetchPaymentCall.call(
              paymentID: getJsonField(
                (_model.createPayment?.jsonBody ?? ''),
                r'''$["paymentId"]''',
              ).toString().toString(),
            );
            if ((_model.autoApiResult?.succeeded ?? true)) {
              if (functions.returnCurrentState(getJsonField(
                    (_model.autoApiResult?.jsonBody ?? ''),
                    r'''$["state"]''',
                  ).toString().toString()) ==
                  'initiated') {
              } else if (functions.returnCurrentState(getJsonField(
                    (_model.autoApiResult?.jsonBody ?? ''),
                    r'''$["state"]''',
                  ).toString().toString()) ==
                  'reserved') {
                _model.captureAmountAPI = await CapturePaymentCall.call(
                  amount: valueOrDefault<int>(
                    widget.amountOfTickets! * 7500,
                    7500,
                  ),
                  paymentId: getJsonField(
                    (_model.createPayment?.jsonBody ?? ''),
                    r'''$["paymentId"]''',
                  ).toString().toString(),
                );
                if ((_model.captureAmountAPI?.succeeded ?? true)) {
                  _model.instantTimer?.cancel();
                  while (_model.loopValue! < widget.amountOfTickets!) {
                    _model.loopValue = _model.loopValue! + 1;

                    await TicketsRecord.collection
                        .doc()
                        .set(createTicketsRecordData(
                          addressName: widget.addressName,
                          address: widget.address,
                          description: widget.description,
                          title:
                              '${FFAppState().teams[widget.homeTeam!].name} VS ${FFAppState().teams[widget.awayTeam!].name}',
                          start: widget.start,
                          userId: currentUserReference,
                          homeTeam: widget.homeTeam,
                          awayTeam: widget.awayTeam,
                        ));
                  }
                  await showAlignedDialog(
                    context: context,
                    isGlobal: true,
                    avoidOverflow: false,
                    targetAnchor: const AlignmentDirectional(0.0, 0.0)
                        .resolve(Directionality.of(context)),
                    followerAnchor: const AlignmentDirectional(0.0, 0.0)
                        .resolve(Directionality.of(context)),
                    builder: (dialogContext) {
                      return Material(
                        color: Colors.transparent,
                        child: WebViewAware(
                            child: GestureDetector(
                          onTap: () => _model.unfocusNode.canRequestFocus
                              ? FocusScope.of(context)
                                  .requestFocus(_model.unfocusNode)
                              : FocusScope.of(context).unfocus(),
                          child: const PaymentCompletedDialogWidget(),
                        )),
                      );
                    },
                  ).then((value) => setState(() {}));
                } else {
                  await showDialog(
                    context: context,
                    builder: (alertDialogContext) {
                      return WebViewAware(
                          child: AlertDialog(
                        title: Text((_model.captureAmountAPI?.statusCode ?? 200)
                            .toString()),
                        content: const Text(
                            'Something went wrong when trying to capture payment. Try again or contact support.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(alertDialogContext),
                            child: const Text('Ok'),
                          ),
                        ],
                      ));
                    },
                  );
                }
              } else if (functions.returnCurrentState(getJsonField(
                    (_model.autoApiResult?.jsonBody ?? ''),
                    r'''$["state"]''',
                  ).toString().toString()) ==
                  'cancelledByMerchant') {
                await showDialog(
                  context: context,
                  builder: (alertDialogContext) {
                    return WebViewAware(
                        child: AlertDialog(
                      title: const Text('Aflyst betaling'),
                      content: const Text('Betalingen er blevet lukket'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(alertDialogContext),
                          child: const Text('Ok'),
                        ),
                      ],
                    ));
                  },
                );
                context.safePop();
              } else if (functions.returnCurrentState(getJsonField(
                    (_model.autoApiResult?.jsonBody ?? ''),
                    r'''$["state"]''',
                  ).toString().toString()) ==
                  'cancelledBySystem') {
                await showDialog(
                  context: context,
                  builder: (alertDialogContext) {
                    return WebViewAware(
                        child: AlertDialog(
                      title: const Text('Lukket betalingen'),
                      content: const Text(
                          'Betalingen er lukket på grund af manglende interaktion med MobilePay'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(alertDialogContext),
                          child: const Text('Ok'),
                        ),
                      ],
                    ));
                  },
                );
                context.safePop();
              } else if (functions.returnCurrentState(getJsonField(
                    (_model.autoApiResult?.jsonBody ?? ''),
                    r'''$["state"]''',
                  ).toString().toString()) ==
                  'cancelledByUser') {
                await showDialog(
                  context: context,
                  builder: (alertDialogContext) {
                    return WebViewAware(
                        child: AlertDialog(
                      title: const Text('Cancelled payment'),
                      content:
                          const Text('Du har afvist betalingen i MobilePay appen'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(alertDialogContext),
                          child: const Text('Ok'),
                        ),
                      ],
                    ));
                  },
                );
                context.safePop();
              } else {
                await showDialog(
                  context: context,
                  builder: (alertDialogContext) {
                    return WebViewAware(
                        child: AlertDialog(
                      title: Text(
                          (_model.autoApiResult?.statusCode ?? 200).toString()),
                      content: const Text(
                          'Something went wrong. Try again or contact support'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(alertDialogContext),
                          child: const Text('Ok'),
                        ),
                      ],
                    ));
                  },
                );
              }
            } else {
              await showDialog(
                context: context,
                builder: (alertDialogContext) {
                  return WebViewAware(
                      child: AlertDialog(
                    title: Text(
                        (_model.autoApiResult?.statusCode ?? 200).toString()),
                    content: const Text(
                        'Something went wrong. Try again or contact support to get help'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(alertDialogContext),
                        child: const Text('Ok'),
                      ),
                    ],
                  ));
                },
              );
              context.safePop();
            }
          },
          startImmediately: true,
        );
      } else {
        await showDialog(
          context: context,
          builder: (alertDialogContext) {
            return WebViewAware(
                child: AlertDialog(
              title: Text((_model.createPayment?.statusCode ?? 200).toString()),
              content: const Text('Noget gik galt. Kontakt support for at få hjælp.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(alertDialogContext),
                  child: const Text('Ok'),
                ),
              ],
            ));
          },
        );
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isiOS) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarBrightness: Theme.of(context).brightness,
          systemStatusBarContrastEnforced: true,
        ),
      );
    }

    context.watch<FFAppState>();

    return Builder(
      builder: (context) => GestureDetector(
        onTap: () => _model.unfocusNode.canRequestFocus
            ? FocusScope.of(context).requestFocus(_model.unfocusNode)
            : FocusScope.of(context).unfocus(),
        child: WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            appBar: AppBar(
              backgroundColor: FlutterFlowTheme.of(context).primary,
              automaticallyImplyLeading: false,
              title: Text(
                'Færdiggør dit køb',
                style: FlutterFlowTheme.of(context).titleMedium,
              ),
              actions: const [],
              centerTitle: false,
              elevation: 2.0,
            ),
            body: SafeArea(
              top: true,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 16.0),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      16.0, 0.0, 16.0, 0.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            12.0, 12.0, 12.0, 12.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                decoration: const BoxDecoration(),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Image.network(
                                                      FFAppState()
                                                          .teams[
                                                              widget.homeTeam!]
                                                          .image,
                                                      width: MediaQuery.sizeOf(
                                                                  context)
                                                              .width *
                                                          1.0,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context,
                                                              error,
                                                              stackTrace) =>
                                                          Image.asset(
                                                        'assets/images/error_image.png',
                                                        width:
                                                            MediaQuery.sizeOf(
                                                                        context)
                                                                    .width *
                                                                1.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    AutoSizeText(
                                                      FFAppState()
                                                          .teams[
                                                              widget.homeTeam!]
                                                          .name,
                                                      textAlign:
                                                          TextAlign.center,
                                                      maxLines: 1,
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyLarge
                                                          .override(
                                                            fontFamily: 'Inter',
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                    ),
                                                  ].divide(
                                                      const SizedBox(height: 12.0)),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                decoration: const BoxDecoration(),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      'VS',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleLarge
                                                              .override(
                                                                fontFamily:
                                                                    'Inter',
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryText,
                                                              ),
                                                    ),
                                                  ].divide(
                                                      const SizedBox(height: 8.0)),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                decoration: const BoxDecoration(),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Image.network(
                                                      FFAppState()
                                                          .teams[
                                                              widget.awayTeam!]
                                                          .image,
                                                      width: MediaQuery.sizeOf(
                                                                  context)
                                                              .width *
                                                          1.0,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context,
                                                              error,
                                                              stackTrace) =>
                                                          Image.asset(
                                                        'assets/images/error_image.png',
                                                        width:
                                                            MediaQuery.sizeOf(
                                                                        context)
                                                                    .width *
                                                                1.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    AutoSizeText(
                                                      FFAppState()
                                                          .teams[
                                                              widget.awayTeam!]
                                                          .name,
                                                      textAlign:
                                                          TextAlign.center,
                                                      maxLines: 1,
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyLarge
                                                          .override(
                                                            fontFamily: 'Inter',
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                    ),
                                                  ].divide(
                                                      const SizedBox(height: 12.0)),
                                                ),
                                              ),
                                            ),
                                          ].divide(const SizedBox(width: 8.0)),
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '#${widget.amountOfTickets?.toString()} Billet(ter)',
                                            style: FlutterFlowTheme.of(context)
                                                .labelMedium
                                                .override(
                                                  fontFamily: 'Inter',
                                                  fontSize: 14.0,
                                                ),
                                          ),
                                          Text(
                                            '${(widget.amountOfTickets! * (widget.amount! / 100)).toString()} kr. i alt',
                                            style: FlutterFlowTheme.of(context)
                                                .labelMedium
                                                .override(
                                                  fontFamily: 'Inter',
                                                  fontSize: 14.0,
                                                ),
                                          ),
                                        ],
                                      ),
                                      Divider(
                                        height: 36.0,
                                        thickness: 1.0,
                                        color: FlutterFlowTheme.of(context)
                                            .alternate,
                                      ),
                                    ].divide(const SizedBox(height: 8.0)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: const AlignmentDirectional(0.00, 1.00),
                          child: Builder(
                            builder: (context) => Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  16.0, 16.0, 16.0, 16.0),
                              child: FFButtonWidget(
                                onPressed: () async {
                                  _model.apiResultb3f =
                                      await FetchPaymentCall.call(
                                    paymentID: getJsonField(
                                      (_model.createPayment?.jsonBody ?? ''),
                                      r'''$["paymentId"]''',
                                    ).toString(),
                                  );
                                  if ((_model.apiResultb3f?.succeeded ??
                                      true)) {
                                    if (functions
                                            .returnCurrentState(getJsonField(
                                          (_model.apiResultb3f?.jsonBody ?? ''),
                                          r'''$["state"]''',
                                        ).toString()) ==
                                        'initiated') {
                                      await showDialog(
                                        context: context,
                                        builder: (alertDialogContext) {
                                          return WebViewAware(
                                              child: AlertDialog(
                                            title: const Text('Betalingen venter'),
                                            content: const Text(
                                                'Du mangler at betale beløbet i MobilePay'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    alertDialogContext),
                                                child: const Text('Ok'),
                                              ),
                                            ],
                                          ));
                                        },
                                      );
                                      await launchURL(getJsonField(
                                        (_model.apiResultb3f?.jsonBody ?? ''),
                                        r'''$["mobilePayAppRedirectUri"]''',
                                      ).toString());
                                    } else if (functions
                                            .returnCurrentState(getJsonField(
                                          (_model.apiResultb3f?.jsonBody ?? ''),
                                          r'''$["state"]''',
                                        ).toString()) ==
                                        'reserved') {
                                      _model.apiResultjnm =
                                          await CapturePaymentCall.call(
                                        amount: valueOrDefault<int>(
                                          widget.amountOfTickets! * 7500,
                                          7500,
                                        ),
                                        paymentId: getJsonField(
                                          (_model.createPayment?.jsonBody ??
                                              ''),
                                          r'''$["paymentId"]''',
                                        ).toString(),
                                      );
                                      if ((_model.apiResultjnm?.succeeded ??
                                          true)) {
                                        while (_model.loopValue! <
                                            widget.amountOfTickets!) {
                                          _model.loopValue =
                                              _model.loopValue! + 1;

                                          await TicketsRecord.collection
                                              .doc()
                                              .set(createTicketsRecordData(
                                                addressName: widget.addressName,
                                                address: widget.address,
                                                description: widget.description,
                                                title:
                                                    '${FFAppState().teams[widget.homeTeam!].name} VS ${FFAppState().teams[widget.awayTeam!].name}',
                                                start: widget.start,
                                                userId: currentUserReference,
                                                homeTeam: widget.homeTeam,
                                                awayTeam: widget.awayTeam,
                                              ));
                                        }
                                        await showAlignedDialog(
                                          context: context,
                                          isGlobal: true,
                                          avoidOverflow: false,
                                          targetAnchor: const AlignmentDirectional(
                                                  0.0, 0.0)
                                              .resolve(
                                                  Directionality.of(context)),
                                          followerAnchor: const AlignmentDirectional(
                                                  0.0, 0.0)
                                              .resolve(
                                                  Directionality.of(context)),
                                          builder: (dialogContext) {
                                            return Material(
                                              color: Colors.transparent,
                                              child: WebViewAware(
                                                  child: GestureDetector(
                                                onTap: () => _model.unfocusNode
                                                        .canRequestFocus
                                                    ? FocusScope.of(context)
                                                        .requestFocus(
                                                            _model.unfocusNode)
                                                    : FocusScope.of(context)
                                                        .unfocus(),
                                                child:
                                                    const PaymentCompletedDialogWidget(),
                                              )),
                                            );
                                          },
                                        ).then((value) => setState(() {}));

                                        if (Navigator.of(context).canPop()) {
                                          context.pop();
                                        }
                                        context.pushNamed('BoughtTicketsPage');
                                      } else {
                                        await showDialog(
                                          context: context,
                                          builder: (alertDialogContext) {
                                            return WebViewAware(
                                                child: AlertDialog(
                                              title: Text((_model.apiResultjnm
                                                          ?.statusCode ??
                                                      200)
                                                  .toString()),
                                              content: const Text(
                                                  'Something went wrong when trying to capture payment. Try again or contact support.'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          alertDialogContext),
                                                  child: const Text('Ok'),
                                                ),
                                              ],
                                            ));
                                          },
                                        );
                                      }
                                    } else if (functions
                                            .returnCurrentState(getJsonField(
                                          (_model.apiResultb3f?.jsonBody ?? ''),
                                          r'''$["state"]''',
                                        ).toString()) ==
                                        'cancelledByMerchant') {
                                      await showDialog(
                                        context: context,
                                        builder: (alertDialogContext) {
                                          return WebViewAware(
                                              child: AlertDialog(
                                            title: const Text('Aflyst betaling'),
                                            content: const Text(
                                                'Betalingen er blevet lukket'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    alertDialogContext),
                                                child: const Text('Ok'),
                                              ),
                                            ],
                                          ));
                                        },
                                      );
                                      context.safePop();
                                    } else if (functions
                                            .returnCurrentState(getJsonField(
                                          (_model.apiResultb3f?.jsonBody ?? ''),
                                          r'''$["state"]''',
                                        ).toString()) ==
                                        'cancelledBySystem') {
                                      await showDialog(
                                        context: context,
                                        builder: (alertDialogContext) {
                                          return WebViewAware(
                                              child: AlertDialog(
                                            title: const Text('Lukket betalingen'),
                                            content: const Text(
                                                'Betalingen er lukket på grund af manglende interaktion med MobilePay'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    alertDialogContext),
                                                child: const Text('Ok'),
                                              ),
                                            ],
                                          ));
                                        },
                                      );
                                      context.safePop();
                                    } else if (functions
                                            .returnCurrentState(getJsonField(
                                          (_model.apiResultb3f?.jsonBody ?? ''),
                                          r'''$["state"]''',
                                        ).toString()) ==
                                        'cancelledByUser') {
                                      await showDialog(
                                        context: context,
                                        builder: (alertDialogContext) {
                                          return WebViewAware(
                                              child: AlertDialog(
                                            title: const Text('Cancelled payment'),
                                            content: const Text(
                                                'Du har afvist betalingen i MobilePay appen'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    alertDialogContext),
                                                child: const Text('Ok'),
                                              ),
                                            ],
                                          ));
                                        },
                                      );
                                      context.safePop();
                                    } else {
                                      await showDialog(
                                        context: context,
                                        builder: (alertDialogContext) {
                                          return WebViewAware(
                                              child: AlertDialog(
                                            title: Text(getJsonField(
                                              (_model.apiResultb3f?.jsonBody ??
                                                  ''),
                                              r'''$["state"]''',
                                            ).toString()),
                                            content: const Text(
                                                'Something went wrong. Try again or contact support'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    alertDialogContext),
                                                child: const Text('Ok'),
                                              ),
                                            ],
                                          ));
                                        },
                                      );
                                    }
                                  } else {
                                    await showDialog(
                                      context: context,
                                      builder: (alertDialogContext) {
                                        return WebViewAware(
                                            child: AlertDialog(
                                          title: Text((_model.apiResultb3f
                                                      ?.statusCode ??
                                                  200)
                                              .toString()),
                                          content: const Text(
                                              'Something went wrong. Try again or contact support to get help'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(
                                                  alertDialogContext),
                                              child: const Text('Ok'),
                                            ),
                                          ],
                                        ));
                                      },
                                    );
                                    context.safePop();
                                  }

                                  setState(() {});
                                },
                                text: 'Har du betalt?',
                                options: FFButtonOptions(
                                  width: MediaQuery.sizeOf(context).width * 1.0,
                                  height: 50.0,
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      24.0, 0.0, 24.0, 0.0),
                                  iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 0.0),
                                  color: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                  textStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: 'Inter',
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                      ),
                                  elevation: 0.0,
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              16.0, 0.0, 16.0, 16.0),
                          child: FFButtonWidget(
                            onPressed: () async {
                              await launchURL(getJsonField(
                                (_model.createPayment?.jsonBody ?? ''),
                                r'''$["mobilePayAppRedirectUri"]''',
                              ).toString());
                            },
                            text: 'Åben MobilePay',
                            options: FFButtonOptions(
                              width: MediaQuery.sizeOf(context).width * 1.0,
                              height: 50.0,
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  24.0, 0.0, 24.0, 0.0),
                              iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 0.0),
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    fontFamily: 'Inter',
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    fontSize: 16.0,
                                  ),
                              elevation: 0.0,
                              borderSide: const BorderSide(
                                color: Colors.transparent,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              16.0, 0.0, 16.0, 0.0),
                          child: Text(
                            'Betaling mangler - Klik på "Åben Mobilepay for at gennemføre"',
                            textAlign: TextAlign.center,
                            style: FlutterFlowTheme.of(context).labelMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: const AlignmentDirectional(0.00, 1.00),
                    child: Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 16.0),
                      child: FFButtonWidget(
                        onPressed: () async {
                          _model.apiResult1wa = await CancelPaymentCall.call(
                            paymentId: getJsonField(
                              (_model.createPayment?.jsonBody ?? ''),
                              r'''$["paymentId"]''',
                            ).toString(),
                          );
                          context.safePop();

                          setState(() {});
                        },
                        text: 'Afbryd betaling',
                        options: FFButtonOptions(
                          width: MediaQuery.sizeOf(context).width * 1.0,
                          height: 50.0,
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              24.0, 0.0, 24.0, 0.0),
                          iconPadding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 0.0),
                          color: const Color(0x001E222B),
                          textStyle: FlutterFlowTheme.of(context)
                              .titleSmall
                              .override(
                                fontFamily: 'Inter',
                                color: FlutterFlowTheme.of(context).secondary,
                              ),
                          elevation: 0.0,
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
