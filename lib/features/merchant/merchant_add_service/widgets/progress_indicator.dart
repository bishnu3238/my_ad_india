import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:my_ad/features/merchant/merchant_add_service/core/merchant_add_service_provider.dart';

class StepProgressIndicator extends StatelessWidget {
  final ServiceFormStep currentStep;
  final VoidCallback? onStepTapped;

  const StepProgressIndicator({
    Key? key,
    required this.currentStep,
    this.onStepTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Step ${_getStepNumber(currentStep)} of 4',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                semanticsLabel: 'Step ${_getStepNumber(currentStep)} of 4',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStepDot(ServiceFormStep.basicInfo, 'Basic Info'),
                _buildStepLine(
                  ServiceFormStep.basicInfo,
                  ServiceFormStep.details,
                ),
                _buildStepDot(ServiceFormStep.details, 'Details'),
                _buildStepLine(ServiceFormStep.details, ServiceFormStep.media),
                _buildStepDot(ServiceFormStep.media, 'Media'),
                _buildStepLine(ServiceFormStep.media, ServiceFormStep.review),
                _buildStepDot(ServiceFormStep.review, 'Review'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepDot(ServiceFormStep step, String label) {
    final isActive = currentStep == step;
    final isCompleted = _getStepNumber(currentStep) > _getStepNumber(step);

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color:
                  isActive
                      ? CupertinoColors.activeBlue
                      : isCompleted
                      ? CupertinoColors.activeGreen
                      : CupertinoColors.systemGrey4,
              shape: BoxShape.circle,
            ),
            child: Center(
              child:
                  isCompleted
                      ? const Icon(
                        CupertinoIcons.check_mark,
                        color: CupertinoColors.white,
                        size: 14,
                      )
                      : Text(
                        '${_getStepNumber(step)}',
                        style: TextStyle(
                          color:
                              isActive
                                  ? CupertinoColors.white
                                  : CupertinoColors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color:
                  isActive
                      ? CupertinoColors.activeBlue
                      : CupertinoColors.systemGrey,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(ServiceFormStep fromStep, ServiceFormStep toStep) {
    final isCompleted = _getStepNumber(currentStep) > _getStepNumber(fromStep);

    return Container(
      width: 20,
      height: 2,
      color:
          isCompleted
              ? CupertinoColors.activeGreen
              : CupertinoColors.systemGrey4,
    );
  }

  int _getStepNumber(ServiceFormStep step) {
    switch (step) {
      case ServiceFormStep.basicInfo:
        return 1;
      case ServiceFormStep.details:
        return 2;
      case ServiceFormStep.media:
        return 3;
      case ServiceFormStep.review:
        return 4;
    }
  }
}
