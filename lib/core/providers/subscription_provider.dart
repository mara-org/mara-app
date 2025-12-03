import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SubscriptionStatus { free, premium }

class SubscriptionNotifier extends StateNotifier<SubscriptionStatus> {
  SubscriptionNotifier() : super(SubscriptionStatus.free);

  void setPremium() {
    state = SubscriptionStatus.premium;
  }

  void setFree() {
    state = SubscriptionStatus.free;
  }
}

final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionStatus>(
  (ref) => SubscriptionNotifier(),
);
