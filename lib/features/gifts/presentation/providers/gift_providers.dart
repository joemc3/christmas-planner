import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/logger.dart';
import '../../data/models/gift_model.dart';
import '../../data/models/recipient_model.dart';
import '../../data/repositories/gift_repository.dart';
import '../../data/repositories/recipient_repository.dart';

// Repository Providers
final recipientRepositoryProvider = Provider<RecipientRepository>((ref) {
  return RecipientRepository();
});

final giftRepositoryProvider = Provider<GiftRepository>((ref) {
  return GiftRepository();
});

// Recipients Stream Provider
final recipientsStreamProvider = StreamProvider<List<RecipientModel>>((ref) {
  final repo = ref.watch(recipientRepositoryProvider);
  return repo.watchRecipients();
});

// Recipient by ID Provider
final recipientByIdProvider = FutureProvider.family<RecipientModel?, String>((ref, id) async {
  final repo = ref.watch(recipientRepositoryProvider);
  return await repo.getRecipientById(id);
});

// Gifts Stream Provider
final giftsStreamProvider = StreamProvider<List<GiftModel>>((ref) {
  final repo = ref.watch(giftRepositoryProvider);
  return repo.watchAllGifts();
});

// Gifts by Recipient Provider
final giftsByRecipientProvider = StreamProvider.family<List<GiftModel>, String>((ref, recipientId) {
  final repo = ref.watch(giftRepositoryProvider);
  return repo.watchGiftsByRecipient(recipientId);
});

// Gift by ID Provider
final giftByIdProvider = FutureProvider.family<GiftModel?, String>((ref, id) async {
  final repo = ref.watch(giftRepositoryProvider);
  return await repo.getGiftById(id);
});

// Gift Budget Stats Provider
final giftBudgetStatsProvider = FutureProvider<Map<String, double>>((ref) async {
  final repo = ref.watch(giftRepositoryProvider);
  return await repo.calculateGiftBudgetStats();
});

// Recipient Controller
final recipientControllerProvider = Provider<RecipientController>((ref) {
  return RecipientController(ref.read(recipientRepositoryProvider));
});

class RecipientController {
  final RecipientRepository _repository;

  RecipientController(this._repository);

  Future<RecipientModel> createRecipient(RecipientModel recipient) async {
    try {
      return await _repository.createRecipient(recipient);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to create recipient', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<RecipientModel> updateRecipient(RecipientModel recipient) async {
    try {
      return await _repository.updateRecipient(recipient);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update recipient', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> deleteRecipient(String id) async {
    try {
      await _repository.deleteRecipient(id);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete recipient', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> archiveRecipient(String id, bool archive) async {
    try {
      await _repository.archiveRecipient(id, archive);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to archive recipient', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}

// Gift Controller
final giftControllerProvider = Provider<GiftController>((ref) {
  return GiftController(ref.read(giftRepositoryProvider));
});

class GiftController {
  final GiftRepository _repository;

  GiftController(this._repository);

  Future<GiftModel> createGift(GiftModel gift) async {
    try {
      return await _repository.createGift(gift);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to create gift', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<GiftModel> updateGift(GiftModel gift) async {
    try {
      return await _repository.updateGift(gift);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update gift', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> deleteGift(String id) async {
    try {
      await _repository.deleteGift(id);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete gift', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> updateGiftStatus(String id, GiftStatus status) async {
    try {
      await _repository.updateGiftStatus(id, status);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update gift status', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
