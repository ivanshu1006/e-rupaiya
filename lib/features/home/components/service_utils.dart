import '../../../constants/file_constants.dart';

String displayServiceName(String name) {
  if (name == 'LPG Gas') return 'Book Gas Cylinder';
  if (name == 'Gas') return 'Pipe Gas';
  if (name == 'Landline Postpaid') return 'Landline';
  if (name == 'Broadband Postpaid') return 'Broadband';
  return name;
}

var serviceIconMap = <String, String>{
  'Mobile Prepaid': FileConstants.mobile,
  'Mobile Postpaid': FileConstants.postpaid,
  'Landline Postpaid': FileConstants.landline,
  'Broadband Postpaid': FileConstants.broadband,
  'DTH': FileConstants.dth,
  'Cable TV': FileConstants.cable,
  'Electricity': FileConstants.electricity,
  'Water': FileConstants.water,
  'Credit Card': FileConstants.credit,
  'Loan Repayment': FileConstants.depositIcon,
  'Recurring Deposit': FileConstants.depositIcon,
  'Insurance': FileConstants.insurance,
  'Life Insurance': FileConstants.lifeInsurance,
  'Prepaid Meter': FileConstants.prepaidMeter,
  'National Pension System': FileConstants.erupaiya_3d,
  'NPS': FileConstants.mobile,
  'Flight Booking': FileConstants.flight,
  'LPG Gas': FileConstants.gasCylinder,
  'Gas': FileConstants.pipegas,
  'Fastag': FileConstants.erupaiya_3d,
  'Train Ticket Booking': FileConstants.train,
  'Hotel Booking': FileConstants.hotel,
};
