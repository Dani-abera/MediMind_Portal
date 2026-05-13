import 'package:get_it/get_it.dart';
import '../../core/network/dio_client.dart';
import 'data/datasources/center_remote_datasource.dart';
import 'data/repositories/center_repository_impl.dart';
import 'domain/repositories/center_repository.dart';
import 'domain/usecases/register_center_usecase.dart';
import 'domain/usecases/get_subscription_plans_usecase.dart';
import 'domain/usecases/initiate_subscription_payment_usecase.dart';
import '../admin/presentation/bloc/registration/subscription_plans_cubit.dart';

final sl = GetIt.instance;

Future<void> initCentersFeature() async {
  sl.registerLazySingleton<CenterRemoteDataSource>(
    () => CenterRemoteDataSourceImpl(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<CenterRepository>(
    () => CenterRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => RegisterCenterUseCase(sl()));
  sl.registerLazySingleton(() => GetSubscriptionPlansUseCase(sl()));
  sl.registerLazySingleton(() => InitiateSubscriptionPaymentUseCase(sl()));
  sl.registerFactory(
    () => SubscriptionPlansCubit(getPlans: sl()),
  );
}
