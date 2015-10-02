# http://docs.mongodb.org/manual/reference/operator/query/
#
# COMPARISON
# ----  -------------------------
# Name	Description
# ----  -------------------------
# $eq	  Matches values that are equal to a specified value.
# $gt	  Matches values that are greater than a specified value.
# $gte	Matches values that are greater than or equal to a specified value.
# $lt	  Matches values that are less than a specified value.
# $lte	Matches values that are less than or equal to a specified value.
# $ne   Matches all values that are not equal to a specified value.
# $in   Matches any of the values specified in an array.
# $nin	Matches none of the values specified in an array.
#
# LOGICAL
# ----  -------------------------
# Name	Description
# ----  -------------------------
# $or	  Joins query clauses with a logical OR    : returns all documents that match the conditions of either clause.
# $and	Joins query clauses with a logical AND   : returns all documents that match the conditions of both clauses.
# $not	Inverts the effect of a query expression : returns documents that do not match the query expression.
# $nor	Joins query clauses with a logical NOR   : returns all documents that fail to match both clauses.
#
# EG
#
# db.inventory.find( { qty: { $gte: 20 } } )
#
# db.inventory.update( { "carrier.fee": { $gte: 2 } }, { $set: { price: 9.99 } } )
#
# db.inventory.find( { $and: [ { price: { $ne: 1.99 } }, { price: { $exists: true } } ] } )
#
# db.inventory.find( { qty: { $nin: [ 5, 15 ] } } )
#
# db.inventory.find( { $or: [ { quantity: { $lt: 20 } }, { price: 10 } ] } )
#
# DB.bars.find(symbol: 'AAPL', $and => [{date: {$gte => '20150615'}}, {date: {$lte => '20150618'}} ])
#
# db.inventory.find( {
#   $and : [
#       { $or : [ { price : 0.99 }, { price : 1.99 } ] },
#       { $or : [ { sale : true }, { qty : { $lt : 20 } } ] }
#     ]
# } )
#
# REGEX SYNTAX
# { <field>: { $regex: /pattern/, $options: '<options>' } }
# { <field>: { $regex: 'pattern', $options: '<options>' } }
# { <field>: { $regex: /pattern/<options> } }
#
# REGEX EG
# { name: { $in: [ /^acme/i, /^ack/ ] } }
# { name: { $regex: /acme.*corp/i, $nin: [ 'acmeblahcorp' ] } }
# { name: { $regex: /acme.*corp/, $options: 'i', $nin: [ 'acmeblahcorp' ] } }
# { name: { $regex: 'acme.*corp', $options: 'i', $nin: [ 'acmeblahcorp' ] } }
#
# REGEX REF
# http://docs.mongodb.org/manual/reference/operator/query/regex/#op._S_regex
#
#
# TODO: add all mongo query and projection stuff

# COMPARISON
$eq      = '$eq'
$ne      = '$ne'
$gt      = '$gt'
$gte     = '$gte'
$lt      = '$lt'
$lte     = '$lte'
$in      = '$in'
$nin     = '$nin'
# LOGICAL
$and     = '$and'
$or      = '$or'
$not     = '$not'
$nor     = '$nor'
# REGEX
$regex   = '$regex'
$options = '$options'



# Include this module or use as module_function.
# EG
#   and( eq(:name, 'Smith'), eq(:dob, '19991231'))
#   =>
#   {"$and"=>[{"name"=>{"$eq"=>"Fred"}}, {"dob"=>{"$eq"=>"19991231"}}]}
module CX; module Mongo
module Query

  module_function

  # COMPARISON OPS
  def eq(    attr, val   );  { attr.to_s => { $eq  => val  } } end
  def ne(    attr, val   );  { attr.to_s => { $ne  => val  } } end
  def gt(    attr, val   );  { attr.to_s => { $gt  => val  } } end
  def ge(    attr, val   );  { attr.to_s => { $gte => val  } } end
  def lt(    attr, val   );  { attr.to_s => { $lt  => val  } } end
  def le(    attr, val   );  { attr.to_s => { $lte => val  } } end
  def in(    attr, *vals );  { attr.to_s => { $in  => vals } } end
  def nin(   attr, *vals );  { attr.to_s => { $nin => vals } } end
  def in_s(  attr, str   );  { attr.to_s => { $in  => str  } } end
  def nin_s( attr, str   );  { attr.to_s => { $nin => str  } } end

  # LOGICAL OPS
  def and( *args ); { $and => args } end # one or more query args
  def or(  *args ); { $or  => args } end # one or more query args
  def nor( *args ); { $nor => args } end # one or more query args
  def not( arg   ); { $not => arg  } end # single query argument only

  # REGEX EXPRESSION
  def rx(pattern, *qualifiers)
    r = { $regex => pattern }
    qualifiers.each {|q| r.merge!(q)}
    r
  end

  # REGEX OPTIONS
  def rxo(string)
    { $options => string.to_s }
  end

  # Intended for use in monkey patching String and Symbol
  module Postfix
    def eq(val);     { self.to_s => { $eq  => val  } } end
    def ne(val);     { self.to_s => { $ne  => val  } } end
    def gt(val);     { self.to_s => { $gt  => val  } } end
    def ge(val);     { self.to_s => { $gte => val  } } end
    def lt(val);     { self.to_s => { $lt  => val  } } end
    def le(val);     { self.to_s => { $lte => val  } } end
    def in(*vals);   { self.to_s => { $in  => vals } } end
    def nin(*vals);  { self.to_s => { $nin => vals } } end
  end
end
end end

# EG
# Using string as an attribute name:
# 'name'.ne('Colin') => {"name"=>{"$gte"=>"Colin"}}
# 'date'.le('20151231') => {"date"=>{"$lte"=>"20151231"}}
#
# Using string as target of $in and $nin operators
# 'abcdefg'.nin => {"$nin"=>"abcdefg"}
class String
  include CX::Mongo::Query::Postfix
  def rxo; CX::Mongo::Query.rxo(self)    end
  def in;  CX::Mongo::Query.in_s(self)   end
  def nin; CX::Mongo::Query.nin_s(self)  end
end

# EG
#
# Using symbol as an attribute name:
# :name.ne('Colin')
# :date.le('20151231')
#
class Symbol
  include CX::Mongo::Query::Postfix
end

# EG
# either
# /.*/.qrx('i'.qrxo, 'abcdefg'))
# or
# $q.regex(/.*/, $q.options('i'), $q.in_string('abcdefg'))
class Regexp
  def rx(*qualifiers)
    CX::Mongo::Query.rx(self, *qualifiers)
  end
end


