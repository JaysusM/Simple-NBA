/*
  This is a simple HashMap data structure different than Dart's one,
  I didn't like Dart's HashMap structure so I created this one with
  approximately same complexity
 */


class HashMap<K,V>
{
  List<Node<K,V>> _nodes;
  List<K> _keys;

  HashMap()
  {
    _nodes = new List();
    _keys = new List();
  }

  void add(K key, V value)
  {
    if(_keys.contains(key)) {
      _nodes.remove(new Node(key, null));
      _nodes.add(new Node(key, value));
    }
    else {
      _keys.add(key);
      _nodes.add(new Node(key, value));
    }
  }

  V getValue(K key)
  {
    if(!_nodes.contains(new Node(key, null)))
      return null;
    return _getNodeFromKey(key).value;
  }

  Node<K,V> _getNodeFromKey (K key)
  {
    for(Node<K,V> n in _nodes)
    {
      if(n._key == key)
        return n;
    }
    return null;
  }

  bool containsKey(K key)
  {
    return keys.contains(key);
  }

  List<K> get keys => _keys;

  List<Node<K, V>> get nodes => _nodes;

  @override
  String toString() {
    return 'HashMap{nodes: $_nodes}';
  }
}

class Node<K,V>
{
  K _key;
  V _value;

  Node(this._key, this._value);

  K get key => _key;
  V get value => _value;

  void setValue (V _value)
  {
    this._value = _value;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Node &&
              runtimeType == other.runtimeType &&
              _key == other._key;

  @override
  int get hashCode => _key.hashCode;

  @override
  String toString() {
    return '{$_key, $_value}';
  }


}