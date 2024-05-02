import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => HomePage(),
      ),
    ],
    errorBuilder: (context, state) => CustomErrorPage(routerState: state),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Demo',
      routerConfig: _router,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const CustomPageHeaderSliver(title: 'HomePage'),
          SliverToBoxAdapter(
            child: Center(
              child: OutlinedButton(
                onPressed: () {
                  GoRouter.of(context).go('/a-non-existing-page');
                },
                child: Text('CLICK ME to go to a page that DOES NOT EXIST'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomErrorPage extends StatelessWidget {
  final GoRouterState routerState;

  const CustomErrorPage({
    super.key,
    required this.routerState,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          CustomPageHeaderSliver(title: 'CustomErrorPage'),
          ..._buildTheActualError(context),
        ],
      ),
    );
  }

  List<Widget> _buildTheActualError(BuildContext context) {
    final error = this.routerState.error;
    if (error == null) {
      return const [];
    }
    return [
      SliverToBoxAdapter(
          child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.error)),
        child: Text(
          error.message,
          textAlign: TextAlign.center,
        ),
      )),
    ];
  }
}

class CustomPageHeaderSliver extends StatelessWidget {
  final String title;

  const CustomPageHeaderSliver({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    // the following will fail on the error page
    bool canPop;
    String? goRouterErrorMessage;
    try {
      canPop = GoRouter.of(context).canPop();
    } catch (err, stack) {
      canPop = false;
      goRouterErrorMessage = '$err: $stack';
      print('Exception: canPop() failed: $err, $stack');
    }

    final errorColor = Theme.of(context).colorScheme.error;
    final hintTextStyle = TextStyle(color: Theme.of(context).hintColor);

    return SliverSafeArea(
      sliver: SliverToBoxAdapter(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            verticalSpacerBox,
            Text(title),
            verticalSpacerBox,
            Text(
                'This is our custom page header (that checks if we can pop this route)',
                style: hintTextStyle),
            if (goRouterErrorMessage != null) ...[
              verticalSpacerBox,
              Text("Uuups! GoRouter.of(context).canPop() failed.",
                  style: TextStyle(
                      color: errorColor, fontWeight: FontWeight.w500)),
              verticalSpacerBox,
              Text(goRouterErrorMessage, style: TextStyle(color: errorColor)),
            ] else if (canPop) ...[
              verticalSpacerBox,
              BackButton(onPressed: () => GoRouter.of(context).pop()),
              Text("canPop failed!", style: TextStyle(color: errorColor)),
            ] else ...[
              Text('there is nothing to pop'),
            ],
            verticalSpacerBox,
          ],
        ),
      ),
    );
  }
}

const verticalSpacerBox = SizedBox(height: 16);
