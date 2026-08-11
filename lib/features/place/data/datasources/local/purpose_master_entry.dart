class PurposeMasterEntry {
  final String id;
  final String name;

  const PurposeMasterEntry({required this.id, required this.name});
}

const List<PurposeMasterEntry> masterPurposeSeedData = [
  PurposeMasterEntry(id: '1', name: '作業'),
  PurposeMasterEntry(id: '2', name: '食事'),
  PurposeMasterEntry(id: '3', name: '休憩'),
  PurposeMasterEntry(id: '4', name: '景色'),
  PurposeMasterEntry(id: '5', name: '人と会う'),
  PurposeMasterEntry(id: '6', name: 'デート'),
];
