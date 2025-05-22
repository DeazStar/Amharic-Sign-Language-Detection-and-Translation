import 'package:camera_app/features/feedback/presentation/bloc/bloc/feedback_bloc.dart';
import 'package:camera_app/features/feedback/presentation/widget/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FeedbackPage extends StatelessWidget {
  final VoidCallback onBack;

  FeedbackPage({required this.onBack, Key? key}) : super(key: key);

  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FeedbackBloc, FeedbackState>(
      listener: (context, state) {
        if (state is FeedbackSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Feedback sent successfully!')),
          );
          _feedbackController.clear();
        } else if (state is FeedbackFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text("Send Feedback")),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _feedbackController,
                    decoration: const InputDecoration(
                      labelText: "Your Feedback",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter feedback'
                        : null,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    label: 'Send',
                    isLoading: state is FeedbackLoading,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<FeedbackBloc>().add(
                              SubmitFeedbackEvent(_feedbackController.text),
                            );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
