DATA_BASEFILE = './data/salaries'
BUFFERED_ATTS = %w(last_name first_name salary)
TAMPERED_ATTS = %w(department title)
# makes a Hash
def data_array
  require 'csv'
  require 'hashie'

  CSV.read("#{DATA_BASEFILE}.csv", headers: true).collect{|a| Hashie::Mash.new(a.to_hash) }
end

def make_data_file
  require 'faker'
  require 'csv'

  include Faker
  depts = 12.times.map{ Commerce.department }.uniq
  titles = 20.times.map{ Name.title }.uniq

  CSV.open("#{DATA_BASEFILE}.csv", 'w', headers: true) do |csv|
    csv << ['id'] + BUFFERED_ATTS + TAMPERED_ATTS

    3500.times do |t|
      csv << [
        t + 1 ,
        Name.last_name,
        Name.first_name,
        rand(25000..250000),
        depts.shuffle.first,
        titles.shuffle.first
      ]
    end
  end
end


def make_json_file
  require 'json'

  open("#{DATA_BASEFILE}.json", 'w'){ |f| f.write data_array.to_json }
end



def make_tamped_json
  require 'tamper'

  data = data_array
  tamped_data = Tamper::PackSet.new
  # set the compressed attributes
  TAMPERED_ATTS.each do |h|
    tamped_data.add_attribute(
      attr_name: h,
      possibilities: data.map{|a| a[h] }.uniq,
      max_choices: 1
    )
  end
  # add buffered
  tamped_data.meta = {
    buffer_url: "#{DATA_BASEFILE}-buffered.json",
    buffer_callback: 'getDetails'
  }
  BUFFERED_ATTS.each do |h|
    tamped_data.add_buffered_attribute(attr_name: h)
  end
  tamped_data.pack!(data)

  open("#{DATA_BASEFILE}-tamped.json", 'w'){ |f| f.write tamped_data.to_json }
  open("#{DATA_BASEFILE}-buffered.json", 'w') do |f|
    f.write data.map{ |d| BUFFERED_ATTS.inject({id: d[:id]}){|h,k| h[k] = d[k]; h} }.to_json
  end
end



def make_basic_page
  require 'erb'

  open("./pages/basic-table.html", "w") do |f|
    @body = %Q{
      <table>
        <thead>
          <tr>
            #{(BUFFERED_ATTS + TAMPERED_ATTS).map{|a| "<th>#{a}</th>"}.join  }
          </tr>
        </thead>
        <tbody>
    }

    data_array.each do |d|
      @body << "<tr>" + (BUFFERED_ATTS + TAMPERED_ATTS).map{|a| "<td>#{d[a]}</td>"}.join + "</tr>"
    end

    erb = ERB.new PAGE_TEMPLATE

    f.write erb.result
  end

end


def make_list_page
  require 'erb'
  open("./pages/list-table.html", "w") do |f|

    @body = ''
    @body << %Q{
      <div id="salaries">
      <input class="search" placeholder="Search" />
      <button class="sort" data-sort="salary">Salary</button>
      <table>
        <thead>
          <tr>
            #{(BUFFERED_ATTS + TAMPERED_ATTS).map{|a| "<th>#{a}</th>"}.join  }
          </tr>
        </thead>
        <tbody class="list">
    }


    data_array.each do |d|
      @body << "<tr>" + (BUFFERED_ATTS + TAMPERED_ATTS).map{|a| "<td class=\"#{a}\">#{d[a]}</td>"}.join + "</tr>"
    end

    @body << %q{</tbody></table></div>}

    @footer = %q{<script src="../javascripts/list.js"></script>}

    @footer += %q{
        <script>
        var options = {
          valueNames: [ 'first_name', 'last_name' ]
        };

        var userList = new List('salaries', options);
        </script>
    }



    erb = ERB.new PAGE_TEMPLATE

    f.write erb.result
  end

end

PAGE_TEMPLATE = %Q{


<html>
  <head>
    <title>Thing</title>

    <!-- styles -->

    <%= @js %>

  </head>
  <body>

     <%= @body %>


    <%= @footer %>

  </body>
</html>
}
