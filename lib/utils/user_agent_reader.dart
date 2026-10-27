import 'user_agent_reader_stub.dart'
    if (dart.library.html) 'user_agent_reader_web.dart'
    if (dart.library.io) 'user_agent_reader_io.dart';

String getUserAgent() => resolveUserAgent();
