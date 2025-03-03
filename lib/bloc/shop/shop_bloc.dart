import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../../repositories/shop_repository.dart';
import 'shop_event.dart';
import 'shop_state.dart';
import '../../models/shop.dart';

class ShopBloc extends Bloc<ShopEvent, ShopState> {
  final ShopRepository shopRepository;
  StreamSubscription<List<Shop>>? _shopsSubscription;

  ShopBloc({required this.shopRepository}) : super(ShopInitial()) {
    on<LoadShops>(_onLoadShops);
    on<LoadShopsByCity>(_onLoadShopsByCity);
    on<LoadShopDetails>(_onLoadShopDetails);
    on<UpdateDeliveryStatus>(_onUpdateDeliveryStatus);
  }
  void _onLoadShops(LoadShops event, Emitter<ShopState> emit) async {
  emit(ShopLoading());
  try {
    await _shopsSubscription?.cancel();

    await emit.forEach(
      shopRepository.getShops(), // ✅ Stream
      onData: (shops) {
        print("✅ Fetched ${shops.length} shops (Limited)");
        return ShopsLoaded(shops);
      },
      onError: (error, stackTrace) {
        print("❌ Error fetching shops: $error");
        return ShopError(error.toString());
      },
    );
  } catch (e) {
    emit(ShopError(e.toString()));
  }
}

void _onLoadShopsByCity(LoadShopsByCity event, Emitter<ShopState> emit) async {
  emit(ShopLoading());
  try {
    Position userPosition = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    await emit.forEach(
      shopRepository.getShopsByCity(event.city, userPosition),
      onData: (shops) => ShopsLoaded(shops),
      onError: (error, stackTrace) => ShopError(error.toString()),
    );
  } catch (e) {
    emit(ShopError(e.toString()));
  }
}

  void _onLoadShopDetails(LoadShopDetails event, Emitter<ShopState> emit) async {
    emit(ShopLoading());
    try {
      final shop = await shopRepository.getShopById(event.shopId);
      emit(ShopDetailLoaded(shop));
    } catch (e) {
      emit(ShopError(e.toString()));
    }
  }
  
  void _onUpdateDeliveryStatus(UpdateDeliveryStatus event, Emitter<ShopState> emit) async {
    try {
      await shopRepository.updateDeliveryStatus(event.shopId, event.delivered);
    } catch (e) {
      emit(ShopError(e.toString()));
    }
  }

 
  @override
  Future<void> close() {
    _shopsSubscription?.cancel(); 
    return super.close();
  }

  @override
  void onTransition(Transition<ShopEvent, ShopState> transition) {
    super.onTransition(transition);
    print("ShopBloc Transition: ${transition.event} -> ${transition.nextState}");
  }
}
