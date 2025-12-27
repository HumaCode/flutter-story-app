import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_story/data/datasources/auth_remote_datasource.dart';
import 'package:my_story/data/datasources/story_remote_datasource.dart';
import 'package:my_story/presentation/auth/blocs/login/login_bloc.dart';
import 'package:my_story/presentation/auth/blocs/logout/logout_bloc.dart';
import 'package:my_story/presentation/auth/blocs/register/register_bloc.dart';
import 'package:my_story/presentation/profile/blocs/profile/profile_bloc.dart';
import 'package:my_story/presentation/story/blocs/create_story/create_story_event_bloc.dart';
import 'package:my_story/presentation/story/blocs/delete_story/delete_story_bloc.dart';
import 'package:my_story/presentation/story/blocs/get_stories/get_stories_event_bloc.dart';
import 'package:my_story/presentation/story/blocs/update_story/update_story_bloc.dart';

final AuthRemoteDatasource _authDatasource = AuthRemoteDatasource();
final StoryRemoteDatasource _storyDatasource = StoryRemoteDatasource();

// ═══════════════════════════════════════════════════════════════
// BLOC PROVIDERS
// ═══════════════════════════════════════════════════════════════

List<BlocProvider> get blocProviders => [
  // Auth BLoCs
  BlocProvider<LoginBloc>(create: (_) => LoginBloc(_authDatasource)),
  BlocProvider<RegisterBloc>(create: (_) => RegisterBloc(_authDatasource)),
  BlocProvider<LogoutBloc>(create: (_) => LogoutBloc(_authDatasource)),

  // Profile BLoC
  BlocProvider<ProfileBloc>(create: (_) => ProfileBloc(_authDatasource)),

  // Story BLoCs
  BlocProvider<GetStoriesBloc>(create: (_) => GetStoriesBloc(_storyDatasource)),
  BlocProvider<CreateStoryBloc>(
    create: (_) => CreateStoryBloc(_storyDatasource),
  ),
  BlocProvider<UpdateStoryBloc>(
    create: (_) => UpdateStoryBloc(_storyDatasource),
  ),
  BlocProvider<DeleteStoryBloc>(
    create: (_) => DeleteStoryBloc(_storyDatasource),
  ),
];

// ═══════════════════════════════════════════════════════════════
// HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════

AuthRemoteDatasource get authDatasource => _authDatasource;
StoryRemoteDatasource get storyDatasource => _storyDatasource;
