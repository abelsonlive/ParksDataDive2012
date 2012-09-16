path_to_file = "~/Desktop/Vizzuality-cartodb-r-05eb537/CartoDB_1.4.tar.gz"
install.packages(path_to_file, repos=NULL, type="source")
require("CartoDB")
account_name = "parks-datadive"
api_key = "[key]"
cartodb(account_name, api_key)
cartodb.test()