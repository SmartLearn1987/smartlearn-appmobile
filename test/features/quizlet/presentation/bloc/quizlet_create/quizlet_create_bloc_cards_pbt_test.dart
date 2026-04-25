// Tag: Feature: quizlet-flashcard, Property 9: Quản lý danh sách thẻ
@Tags(['quizlet-flashcard-property-9'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group;
import 'package:mocktail/mocktail.dart' hide any;
import 'package:smart_learn/features/quizlet/domain/usecases/create_quizlet_use_case.dart';
import 'package:smart_learn/features/quizlet/domain/usecases/get_quizlet_detail_use_case.dart';
import 'package:smart_learn/features/quizlet/domain/usecases/update_quizlet_use_case.dart';
import 'package:smart_learn/features/quizlet/presentation/bloc/quizlet_create/quizlet_create_bloc.dart';
import 'package:smart_learn/features/quizlet/presentation/helpers/csv_import_helper.dart';
import 'package:smart_learn/features/subjects/domain/usecases/get_subjects_use_case.dart';

class MockCreateQuizletUseCase extends Mock implements CreateQuizletUseCase {}

class MockUpdateQuizletUseCase extends Mock implements UpdateQuizletUseCase {}

class MockGetQuizletDetailUseCase extends Mock
    implements GetQuizletDetailUseCase {}

class MockGetSubjectsUseCase extends Mock implements GetSubjectsUseCase {}

Generator<String> get _nonEmptyString =>
    any.letterOrDigits.map((s) => s.isEmpty ? 'a' : s);

Generator<CardFormData> get _cardData => any.combine2(
      _nonEmptyString,
      _nonEmptyString,
      (term, definition) => CardFormData(term: term, definition: definition),
    );

void main() {
  group('Property 9: Quản lý danh sách thẻ (thêm/xóa)', () {
    Glados(
      any.listWithLengthInRange(2, 20, _cardData),
      ExploreConfig(numRuns: 100),
    ).test(
      'AddCard tăng độ dài 1, RemoveCard tuân thủ ngưỡng tối thiểu 2',
      (cards) async {
        final bloc = QuizletCreateBloc(
          MockCreateQuizletUseCase(),
          MockUpdateQuizletUseCase(),
          MockGetQuizletDetailUseCase(),
          MockGetSubjectsUseCase(),
        );

        bloc.emit(QuizletCreateState(cards: cards));

        bloc.add(const AddCard());
        await Future<void>.delayed(Duration.zero);
        final afterAdd = bloc.state.cards;
        expect(afterAdd.length, equals(cards.length + 1));
        expect(afterAdd.last, const CardFormData.empty());

        bloc.emit(QuizletCreateState(cards: afterAdd));
        bloc.add(const RemoveCard(0));
        await Future<void>.delayed(Duration.zero);
        final afterRemove = bloc.state.cards;
        expect(afterRemove.length, equals(afterAdd.length - 1));

        final minCardsBloc = QuizletCreateBloc(
          MockCreateQuizletUseCase(),
          MockUpdateQuizletUseCase(),
          MockGetQuizletDetailUseCase(),
          MockGetSubjectsUseCase(),
        );
        minCardsBloc.emit(
          const QuizletCreateState(
            cards: [CardFormData.empty(), CardFormData.empty()],
          ),
        );
        minCardsBloc.add(const RemoveCard(0));
        await Future<void>.delayed(Duration.zero);
        expect(minCardsBloc.state.cards.length, equals(2));

        await bloc.close();
        await minCardsBloc.close();
      },
    );
  });
}
