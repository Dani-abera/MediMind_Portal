import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../../domain/entities/center_branding.dart';
import '../../../domain/usecases/get_center_branding_usecase.dart';
import '../../../domain/usecases/save_center_branding_usecase.dart';
import '../../../domain/usecases/upload_center_image_usecase.dart';

part 'branding_event.dart';
part 'branding_state.dart';

class BrandingBloc extends Bloc<BrandingEvent, BrandingState> {
  final GetCenterBrandingUseCase _getCenterBranding;
  final SaveCenterBrandingUseCase _saveCenterBranding;
  final UploadCenterImageUseCase _uploadCenterImage;

  String _centerId = '';
  CenterBranding _branding = const CenterBranding();

  BrandingBloc({
    required GetCenterBrandingUseCase getCenterBranding,
    required SaveCenterBrandingUseCase saveCenterBranding,
    required UploadCenterImageUseCase uploadCenterImage,
  })  : _getCenterBranding = getCenterBranding,
        _saveCenterBranding = saveCenterBranding,
        _uploadCenterImage = uploadCenterImage,
        super(const BrandingInitial()) {
    on<BrandingStarted>(_onStarted, transformer: droppable());
    on<BrandingDescriptionChanged>(_onDescriptionChanged);
    on<BrandingImageSelected>(_onImageSelected, transformer: sequential());
    on<BrandingSubmitted>(_onSubmitted, transformer: droppable());
  }

  Future<void> _onStarted(BrandingStarted event, Emitter<BrandingState> emit) async {
    _centerId = event.centerId;
    emit(const BrandingLoading());
    final result = await _getCenterBranding(_centerId);
    result.fold(
      (f) => emit(BrandingError(f.message)),
      (branding) {
        _branding = branding;
        emit(BrandingLoaded(branding));
      },
    );
  }

  void _onDescriptionChanged(BrandingDescriptionChanged event, Emitter<BrandingState> emit) {
    _branding = _branding.copyWith(description: event.text);
    emit(BrandingLoaded(_branding));
  }

  Future<void> _onImageSelected(BrandingImageSelected event, Emitter<BrandingState> emit) async {
    emit(BrandingUploading(event.imageType));
    final result = await _uploadCenterImage(_centerId, event.imageType, event.filePath);
    result.fold(
      (f) => emit(BrandingError(f.message)),
      (url) {
        if (event.imageType == 'logo') {
          _branding = _branding.copyWith(logoUrl: url);
        } else {
          _branding = _branding.copyWith(coverUrl: url);
        }
        emit(BrandingUploadDone(event.imageType, url));
        emit(BrandingLoaded(_branding));
      },
    );
  }

  Future<void> _onSubmitted(BrandingSubmitted event, Emitter<BrandingState> emit) async {
    emit(const BrandingSaving());
    final result = await _saveCenterBranding(_centerId, _branding);
    result.fold(
      (f) => emit(BrandingError(f.message)),
      (branding) {
        _branding = branding;
        emit(const BrandingSaved());
        emit(BrandingLoaded(_branding));
      },
    );
  }
}
