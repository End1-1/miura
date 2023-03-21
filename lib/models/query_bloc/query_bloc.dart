import 'dart:typed_data';

import 'package:cafe5_shop_mobile_client/models/query_bloc/query_action.dart';
import 'package:cafe5_shop_mobile_client/models/query_bloc/query_state.dart';
import 'package:cafe5_shop_mobile_client/socket_message.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../client_socket.dart';
import '../../client_socket_interface.dart';
import '../../translator.dart';

class QueryBloc extends Bloc<QueryAction, QueryState>
    implements SocketInterface {
  QueryBloc(super.initialState) {
    ClientSocket.socket.addInterface(this);
    on<QueryActionLoad>((event, emit) => _actionLoad(event));
    on<QueryActionFilter>((event, emit) => emit(QueryStateFilter(filter: event.filter)));
    on<QueryActionShowFilter>((event, emit) => emit(QueryStateShowFilter()));
  }

  @override
  void authenticate() {
    // TODO: implement authenticate
  }

  @override
  void connected() {
    // TODO: implement connected
  }

  @override
  void disconnected() {
    if (!isClosed) {
      emit(QueryStateError(error: tr('Disconnected from server')));
    }
  }

  @override
  void handler(Uint8List data) {
    SocketMessage m = SocketMessage(messageId: 0, command: 0);
    m.setBuffer(data);

    print("command ${m.command}");
    if (m.command == SocketMessage.c_dllplugin) {
      int op = m.getInt();
      int dllok = m.getByte();
      if (dllok == 0) {
        emit(QueryStateError(error: m.getString()));
        return;
      }
      String json = m.getString();
      emit(QueryStateReady(op: op, data: json));
    }
  }

  void _actionLoad(QueryAction a) {
    if (a is QueryActionShowFilter) {
      emit(QueryStateShowFilter());
      return;
    }
    emit(const QueryStateProgress());
    if (a is QueryActionLoad) {
      SocketMessage m = SocketMessage.dllplugin(a.op);
      if (a.optional != null) {
        for (var o in a.optional!) {
          if (o is int) {
            m.addInt(o);
          } else if (o is String) {
            m.addString(o);
          } else if (o is double) {
            m.addDouble(o);
          }
        }
      }
      ClientSocket.send(m);
    } else if (a is QueryActionFilter) {
      emit(QueryStateFilter(filter: a.filter));
    }
  }
}
