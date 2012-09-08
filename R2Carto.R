path_to_file = "~/Desktop/Vizzuality-cartodb-r-05eb537/CartoDB_1.4.tar.gz"
install.packages(path_to_file, repos=NULL, type="source")
require("CartoDB")
account_name = "parks-datadive"
api_key = "4bcaf7ac1d56757cd065732b59b854f139d9ea67"
cartodb(account_name, api_key)
cartodb.test()