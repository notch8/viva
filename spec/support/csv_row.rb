# frozen_string_literal: true

##
# The purpose of this class is to provide a cheap means of simulating a CSV row with headers.
#
# For the most part a Csv::Row (when headers are enabled) is like a Hash.  Except, the row does not
# have a {#keys} method (though it does have a {#key?} method).  Instead it has a headers method.
#
# So the following class extends a Hash object and adds the {#headers} method.
class CsvRow < DelegateClass(Hash)
  def headers
    keys
  end
end
