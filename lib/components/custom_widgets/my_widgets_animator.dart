import 'package:flutter/cupertino.dart';

import '../../utils/enum.dart';
import 'custom_progreess_indicator.dart';

// switch between different widgets with animation
// depending on api call status

class MyWidgetsAnimator extends StatelessWidget {
  final ApiCallStatus apiCallStatus;
  final Widget Function()? loadingWidget;
  final Widget Function() successWidget;
  final Widget Function() errorWidget;
  final Widget Function()? emptyWidget;
  final Widget Function()? holdingWidget;
  final Widget Function()? refreshWidget;
  final Duration? animationDuration;
  final Widget Function(Widget, Animation<double>)? transitionBuilder;

  // this will be used to not hide the success widget when refresh
  // if its true success widget will still be shown
  // if false refresh widget will be shown or empty box if passed (refreshWidget) is null
  final bool hideSuccessWidgetWhileRefreshing;

  const MyWidgetsAnimator({
    super.key,
    required this.apiCallStatus,
     this.loadingWidget,
    required this.errorWidget,
    required this.successWidget,
    this.holdingWidget,
    this.emptyWidget,
    this.refreshWidget,
    this.animationDuration,
    this.transitionBuilder,
    this.hideSuccessWidgetWhileRefreshing = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: animationDuration ?? const Duration(milliseconds: 0),
      child: switch (apiCallStatus) {
        (ApiCallStatus.success) => successWidget,
        (ApiCallStatus.error) => errorWidget,
        (ApiCallStatus.holding) => holdingWidget ??
            () {
              return const SizedBox();
            },
        (ApiCallStatus.loading) => loadingWidget ??
            () {
              return const CustomProgressIndicator();
            },
        (ApiCallStatus.empty) => emptyWidget ??
            () {
              return const SizedBox();
            },
        (ApiCallStatus.refresh) => refreshWidget ??
            (hideSuccessWidgetWhileRefreshing
                ? successWidget
                : () {
                    return const SizedBox();
                  }),
        (ApiCallStatus.cache) => successWidget,
      }(),
      //transitionBuilder: transitionBuilder ?? AnimatedSwitcher.defaultTransitionBuilder
    );
  }
}

//
// class MyWidgetsAnimator extends StatelessWidget {
//   final AppState apiCallStatus;
//   final Widget Function() loadingWidget;
//   final Widget Function() successWidget;
//   final Widget Function() errorWidget;
//   final Widget Function()? emptyWidget;
//   final Widget Function()? holdingWidget;
//   final Widget Function()? refreshWidget;
//   final Duration? animationDuration;
//   final Widget Function(Widget, Animation<double>)? transitionBuilder;
//   // this will be used to not hide the success widget when refresh
//   // if its true success widget will still be shown
//   // if false refresh widget will be shown or empty box if passed (refreshWidget) is null
//   final bool hideSuccessWidgetWhileRefreshing;
//
//
//   const MyWidgetsAnimator(
//       {super.key,
//         required this.apiCallStatus,
//         required this.loadingWidget,
//         required this.errorWidget,
//         required this.successWidget,
//         this.holdingWidget,
//         this.emptyWidget,
//         this.refreshWidget,
//         this.animationDuration,
//         this.transitionBuilder,
//         this.hideSuccessWidgetWhileRefreshing = false,
//       });
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedSwitcher(
//       duration: animationDuration ?? const Duration(milliseconds: 0),
//       child: Builder(builder: (context){
//         if(apiCallStatus is LoadingState){
//           return loadingWidget();
//         }else if(apiCallStatus is SuccessState){
//           return successWidget();
//         }if(apiCallStatus is ErrorState){
//           return errorWidget();
//         }else if(apiCallStatus is EmptyState){
//           return const SizedBox(child: Text("Emoty"),);
//         }
//         return const SizedBox();
//       }),
//       // child: switch(apiCallStatus.runtimeType){
//       //   (ApiCallStatus.success) => successWidget,
//       //   (ApiCallStatus.error) => errorWidget,
//       //   (ApiCallStatus.holding) => holdingWidget ?? () { return const SizedBox();},
//       //   (ApiCallStatus.loading) => loadingWidget,
//       //   (ApiCallStatus.empty) => emptyWidget ?? (){return const SizedBox();},
//       //   (ApiCallStatus.refresh) => refreshWidget ?? (hideSuccessWidgetWhileRefreshing ? successWidget :  (){return const SizedBox();}),
//       //   (ApiCallStatus.cache) => successWidget,
//       // }(),
//       //transitionBuilder: transitionBuilder ?? AnimatedSwitcher.defaultTransitionBuilder
//     );
//   }
// }
//
//
// abstract class AppState {}
//
//
// class LoadingState extends AppState {
//   @override
//   String toString() => 'Loading State';
// }
//
// class EmptyState extends AppState {
//
//   @override
//   String toString() => 'Loading State';
// }
//
// // Loaded state with data
// class SuccessState extends AppState {
//   final String data;
//
//   SuccessState([this.data=""]);
//
//   @override
//   String toString() => data;
// }
//
// // Error state with an error message
// class ErrorState extends AppState {
//   final String errorMessage;
//
//   ErrorState(this.errorMessage);
//
//   @override
//   String toString() => errorMessage;
// }
