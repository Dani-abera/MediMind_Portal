import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/network/user_context.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/shell/page_header.dart';
import '../presentation/bloc/branding/branding_bloc.dart';

class CenterBrandingPage extends StatelessWidget {
  const CenterBrandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BrandingBloc>()
        ..add(BrandingStarted(UserContext().centerId ?? '')),
      child: const _BrandingView(),
    );
  }
}

class _BrandingView extends StatefulWidget {
  const _BrandingView();

  @override
  State<_BrandingView> createState() => _BrandingViewState();
}

class _BrandingViewState extends State<_BrandingView> {
  final _descriptionCtrl = TextEditingController();
  bool _populated = false;

  @override
  void dispose() {
    _descriptionCtrl.dispose();
    super.dispose();
  }

  void _populate(BrandingLoaded state) {
    if (_populated) return;
    _populated = true;
    _descriptionCtrl.text = state.branding.description;
  }

  Future<void> _pickImage(BuildContext ctx, String imageType) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null && ctx.mounted) {
      ctx.read<BrandingBloc>().add(BrandingImageSelected(imageType, file.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BrandingBloc, BrandingState>(
      listener: (ctx, state) {
        if (state is BrandingLoaded && !_populated) {
          setState(() => _populate(state));
        }
        if (state is BrandingSaved) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(content: Text('Branding saved successfully')),
          );
        }
        if (state is BrandingUploadDone) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text('${state.imageType} uploaded successfully')),
          );
        }
        if (state is BrandingError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.danger),
          );
        }
      },
      child: BlocBuilder<BrandingBloc, BrandingState>(
        builder: (ctx, state) {
          final branding = state is BrandingLoaded ? state.branding : null;
          final isLoading = state is BrandingLoading;
          final isSaving = state is BrandingSaving;
          final isUploadingLogo = state is BrandingUploading && state.imageType == 'logo';
          final isUploadingCover = state is BrandingUploading && state.imageType == 'cover';

          return Column(
            children: [
              const PageHeader(
                title: 'Center Settings',
                subtitle: 'Branding',
              ),
              if (isLoading)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _imageCard(
                                label: 'Logo',
                                imageUrl: branding?.logoUrl,
                                isUploading: isUploadingLogo,
                                onUpload: () => _pickImage(ctx, 'logo'),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.base),
                            Expanded(
                              child: _imageCard(
                                label: 'Cover',
                                imageUrl: branding?.coverUrl,
                                isUploading: isUploadingCover,
                                onUpload: () => _pickImage(ctx, 'cover'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          'Description',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.neutral600),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextFormField(
                          controller: _descriptionCtrl,
                          minLines: 5,
                          maxLines: 12,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Describe your healthcare center...',
                          ),
                          onChanged: (v) =>
                              ctx.read<BrandingBloc>().add(BrandingDescriptionChanged(v)),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton(
                            onPressed: isSaving
                                ? null
                                : () => ctx.read<BrandingBloc>().add(const BrandingSubmitted()),
                            child: isSaving
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('Save Branding'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _imageCard({
    required String label,
    required String? imageUrl,
    required bool isUploading,
    required VoidCallback onUpload,
  }) =>
      Container(
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.neutral200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isUploading)
              const CircularProgressIndicator()
            else if (imageUrl != null && imageUrl.isNotEmpty)
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
                  child: Image.network(
                    imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.image_outlined, size: 48, color: AppColors.neutral300),
                  ),
                ),
              )
            else
              const Icon(Icons.image_outlined, size: 48, color: AppColors.neutral300),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton(
              onPressed: onUpload,
              child: Text('Upload $label'),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      );
}
