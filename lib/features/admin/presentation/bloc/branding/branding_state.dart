part of 'branding_bloc.dart';

abstract class BrandingState extends Equatable {
  const BrandingState();
  @override
  List<Object?> get props => [];
}

class BrandingInitial extends BrandingState {
  const BrandingInitial();
}

class BrandingLoading extends BrandingState {
  const BrandingLoading();
}

class BrandingLoaded extends BrandingState {
  final CenterBranding branding;
  const BrandingLoaded(this.branding);
  @override
  List<Object?> get props => [branding];
}

class BrandingUploading extends BrandingState {
  final String imageType;
  const BrandingUploading(this.imageType);
  @override
  List<Object?> get props => [imageType];
}

class BrandingUploadDone extends BrandingState {
  final String imageType;
  final String url;
  const BrandingUploadDone(this.imageType, this.url);
  @override
  List<Object?> get props => [imageType, url];
}

class BrandingSaving extends BrandingState {
  const BrandingSaving();
}

class BrandingSaved extends BrandingState {
  const BrandingSaved();
}

class BrandingError extends BrandingState {
  final String message;
  const BrandingError(this.message);
  @override
  List<Object?> get props => [message];
}
