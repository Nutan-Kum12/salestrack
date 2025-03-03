import 'package:equatable/equatable.dart';

abstract class ShopEvent extends Equatable {
  const ShopEvent();

  @override
  List<Object?> get props => [];
}

class LoadShops extends ShopEvent {}

class LoadMoreShops extends ShopEvent {} 

class LoadShopsByCity extends ShopEvent {
  final String city;

  const LoadShopsByCity(this.city);

  @override
  List<Object?> get props => [city];
}

class LoadShopDetails extends ShopEvent {
  final String shopId;

  const LoadShopDetails(this.shopId);

  @override
  List<Object?> get props => [shopId];
}

class UpdateDeliveryStatus extends ShopEvent {
  final String shopId;
  final bool delivered;

  const UpdateDeliveryStatus(this.shopId, this.delivered);

  @override
  List<Object?> get props => [shopId, delivered];
}
