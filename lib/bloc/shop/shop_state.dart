import 'package:equatable/equatable.dart';
import '../../models/shop.dart';

abstract class ShopState extends Equatable {
  const ShopState();

  @override
  List<Object?> get props => [];
}

class ShopInitial extends ShopState {}

class ShopLoading extends ShopState {}

class ShopsLoaded extends ShopState {
  final List<Shop> shops;

  const ShopsLoaded(this.shops);

  @override
  List<Object?> get props => [shops];
}

class ShopDetailLoaded extends ShopState {
  final Shop shop;

  const ShopDetailLoaded(this.shop);

  @override
  List<Object?> get props => [shop];
}

class ShopError extends ShopState {
  final String message;

  const ShopError(this.message);

  @override
  List<Object?> get props => [message];
}

