import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../provider.dart';
import '../../styleutil.dart';
import '../../util.dart';
import '../application/calendar_bloc.dart';
import '../application/calendar_event.dart';
import '../application/calendar_state.dart';

class AppcalendarScreen extends StatelessWidget {
  const AppcalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CalendarBloc>(
      create: (_) => CalendarBloc(),
      child: BlocBuilder<CalendarBloc, CalendarState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              scrolledUnderElevation: 0,
              backgroundColor: ColorMainBack,
              centerTitle: true,
              title: Text('달력', style: TextAppbar),
              leading: IconButton(
                onPressed: () {
                  popWithSlideAnimation(context, 2);
                  bottomShow(context);
                },
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all<Color>(
                    Colors.transparent,
                  ),
                ),
                icon: Icon(Icons.chevron_left, size: 30),
              ),
            ),
            body: SingleChildScrollView(
              child:Column(
                children: [
                  const SizedBox(height: 24),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 850,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      // color: const Color.fromRGBO(71, 71, 71, 1)
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 0),
                          child: DefaultTextStyle(
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.amber),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    _button(
                                        onTap: () => context
                                            .read<CalendarBloc>()
                                            .add(CalendarChangeEvent(
                                            isNext: false)),
                                        icon: Icons.arrow_back_ios_rounded),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      child: Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            20, 5, 20, 5),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            width: 2,
                                            color: Colors.grey.withOpacity(0.0),
                                          ),
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        child: Text(
                                          "${state.calendar.year}년 ${state.calendar.month}월",
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 25,
                                          ),
                                        ),
                                      ),
                                    ),
                                    _button(
                                        onTap: () => context
                                            .read<CalendarBloc>()
                                            .add(CalendarChangeEvent(
                                            isNext: true)),
                                        icon: Icons.arrow_forward_ios_rounded),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Wrap(
                          children: [
                            ...List.generate(
                              7,
                                  (index) => SizedBox(
                                height:MediaQuery.of(context).size.width / 7.0001,
                                width: MediaQuery.of(context).size.width / 7.0001,
                                child: Center(
                                  child: Text(
                                    ["일", "월", "화", "수", "목", "금", "토"][index],
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.grey.withOpacity(0.7)),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Stack(
                          children: [
                            GestureDetector(
                              onHorizontalDragEnd: (details) => context
                                  .read<CalendarBloc>()
                                  .add(CalendarEndBlurEvent(endDetails: details)),
                              onHorizontalDragUpdate: (details) => context
                                  .read<CalendarBloc>()
                                  .add(CalendarUpdateBlurEvent(
                                  updateDetails: details)),
                              child: Wrap(
                                children: [
                                  ...List.generate(
                                    state.calendar.days.length,
                                        (index) => BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: state.blur,
                                        sigmaY: state.blur,
                                      ),
                                      child: InkWell(
                                        onTap: () => context
                                            .read<CalendarBloc>()
                                            .add(CalendarClickEvent(
                                          selectedDate: DateTime(
                                              state.calendar.year,
                                              state.calendar.month,
                                              state.calendar.days[index]),
                                        )),
                                        child: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(3),
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: const Color.fromRGBO(
                                                          71, 71, 71, 1)),
                                                  shape: BoxShape.circle,
                                                  color: (state.calendar.year ==
                                                      DateTime.now()
                                                          .year &&
                                                      state.calendar.month ==
                                                          DateTime.now()
                                                              .month &&
                                                      state.calendar
                                                          .days[index] ==
                                                          DateTime.now().day)
                                                      ? Colors.white
                                                      : const Color.fromRGBO(
                                                      71, 71, 71, 1)),
                                              height: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                                  7.0001,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                                  7.0001,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 4, top: 4),
                                                child: Text(
                                                  state.calendar.days[index] == 0
                                                      ? ""
                                                      : state.calendar.days[index]
                                                      .toString(),
                                                  style: TextStyle(
                                                    fontWeight: (state.calendar
                                                        .year ==
                                                        DateTime.now()
                                                            .year &&
                                                        state.calendar
                                                            .month ==
                                                            DateTime.now()
                                                                .month &&
                                                        state.calendar.days[
                                                        index] ==
                                                            DateTime.now()
                                                                .day)
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                    color: Colors.black,
                                                    fontSize: 20,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              child: 1 == 1
                                                  ? Text('2027')
                                                  : Text('2028'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        Text(state.selectedDate.day.toString()),

                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  GestureDetector _button({
    required Function() onTap,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        icon,
        size: 20,
        color: Colors.black,
      ),
    );
  }
}
