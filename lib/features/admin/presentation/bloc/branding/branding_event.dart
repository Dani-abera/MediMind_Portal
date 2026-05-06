part of 'branding_bloc.dart';

abstract class BrandingEvent extends Equatable {
  const BrandingEvent();
  @override
  List<Object?> get props => [];
}

class BrandingStarted extends BrandingEvent {
  final String centerId;
  const BrandingStarted(this.centerId);
  @override
  List<Object?> get props => [centerId];
}

class BrandingDescriptionChanged extends BrandingEvent {
  final String text;
  const BrandingDescriptionChanged(this.text);
  @override
  List<Object?> get props => [text];
}

class BrandingImageSelected extends BrandingEvent {
  final String imageType;
  final String filePath;
  const BrandingImageSelected(this.imageType, this.filePath);
  @override
  List<Object?> get props => [imageType, filePath];
}

class BrandingSubmitted extends BrandingEvent {
  const BrandingSubmitted();
}
