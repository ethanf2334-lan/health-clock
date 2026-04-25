String memberRelationLabel(String? relation) {
  const labels = {
    'self': '本人',
    'father': '父亲',
    'mother': '母亲',
    'spouse': '配偶',
    'child': '子女',
    'other': '其他',
  };
  if (relation == null || relation.trim().isEmpty) return '未设置关系';
  return labels[relation] ?? relation;
}
