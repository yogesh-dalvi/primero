# state array
LOCATION_ARRAY = [['--select--',nil],['Maharashtra', "maharashtra_94827"], ['Delhi', "delhi_64730"],['NCW','ncw_37432']]



# Location array/district array
MAHARASHTRA = [['--clear--',nil],['Dadar','dadar_41085'],['Kandivali','kandivali_80846'],['CBD Belapur','cbd_belapur_91917'],['Kurla','kurla_84966'],['Vakola','vakola_11821'],['Vikhroli','vikhroli_82157'],['Nashik','nashik_66641'],['Dhule','dhule_65349'],['Pune','pune_75723'],['Nanded','nanded_83848'],['Aurangabad','aurangabad_86607'],['Yawatmal','yawatmal_66643'],['Wardha','wardha_68524']]
DELHI = [['--clear--',nil],['Malviya Nagar','malviya_nagar_13216'],['Sabji Mandi','sabji_mandi_46220'],['Rani Bagh','rani_bagh_07203'],['Nand Nagri','nand_nagri_62927'],['kamla_market_35409','Kamla Market'],['Mandir Marg','mandir_marg_39616'],['Saket','saket_32633'],['Dwarka','dwarka_77685'],['Sri Niwas Puri','sri_niwas_puri_31688'],['Gazipur','gazipur_51503'],['Kirti Nagar','kirti_nagar_21146'],['Rohini','rohini_96317'],['Police Line','police_line_08887'],['Shahdara','shahdara_31895'],['Delhi Cantt','delhi_cantt_47837']]
NCW = [['--clear--',nil],['Assam','assam_0122'],['Meghalaya','meghalaya_0122'],['Tamil Nadu','tamil_nadu_0122'],['Bihar','bihar_0122'],['Punjab','punjab_0122'],['Madhya Pradesh','madhya_pradesh_0122'],['Odisha','odisha_0122']]
#---------------------------------------------------------

#cells of NCW district. you can add cell of any other district if present bt remember to add its key in "CELL_MAP_ARRAY"
NCW_ASSAM_LOCATION = [['--clear--',nil],['Kamrup','kamrup_50427']]
NCW_MEGHALAYA_LOCATION = [['--clear--',nil],['East Khasi Hills-Shillong','east_khasi_hills_shillong_87706']]
NCW_TAMILNADU_LOCATION = [['--clear--',nil],['Greater Chennai','greater_chennai_34441'],['Salem','salem_11540'],['Tirunelveli','tirunelveli_12999'],['Madurai','madurai_33273']]
NCW_BIHAR_LOCATION = [['--clear--',nil],['Darbhanga','darbhanga_12348'],['Bhagalpur','bhagalpur_25471'],['Kishanganj','kishanganj_30608'],['Motihari','motihari_65516'],['Gaya','gaya_64319']]
NCW_PUNJAB_LOCATION = [['--clear--',nil],['Ludhiana','ludhiana_21666'],['Amritsar','amritsar_38191'],['SAS Nagar-Mohali','sas_nagar_mohali_46942']]
NCW_MADHYAPRADESH_LOCATION = [['--clear--',nil],['Bhopal','bhopal_64801'],['Gwalior','gwalior_06952'],['Indore','indore_27065'],['Jabalpur','jabalpur_64771'],['Sagar','sagar_98240']]
NCW_ODISHA_LOCATION = [['--clear--',nil],['Balasore','balasore_13891'],['Rourkela','rourkela_46570']]

#------------------------------------------------------------

# MAPPING FOR DISTRICTS HAVING MULTIPlE CELLS
CELL_MAP_ARRAY = {:assam_0122 => NCW_ASSAM_LOCATION,:meghalaya_0122 => NCW_MEGHALAYA_LOCATION,:tamil_nadu_0122 => NCW_TAMILNADU_LOCATION,:bihar_0122 => NCW_BIHAR_LOCATION,:punjab_0122 => NCW_PUNJAB_LOCATION,:madhya_pradesh_0122 => NCW_MADHYAPRADESH_LOCATION,:odisha_0122 => NCW_ODISHA_LOCATION} #add cell only if a district has multiple cells

# mapping state and its location array
# LOCATION_MAP_ARRAY=[["maharashtra_94827",MAHARASHTRA],["delhi_64730",DELHI],["ncw_37432",NCW]]
# MAP A STATE WITH ITS KEY
LOCATION_MAP_ARRAY={:maharashtra_94827 => MAHARASHTRA, :delhi_64730 => DELHI,:ncw_37432 => NCW} # add only state if a new state comes

# mapping LOCATIONS having multiple LOCATIONS AND THAT LOCATIONS ARE HAVING THERE OWN CELL
# LOCATION_WITH_MULTIPLE_LOCATION_LOOKUP=["ncw_37432"]
# LOCATION_WITH_MULTIPLE_LOCATION_MAP_ARRAY=[["ncw_37432",NCW]]

MONTH_ARRAY = [['--select--',nil],['January','01'],['February','02'],['March','03'],['April','04'],['May','05'],['June','06'],['July','07'],['August','08'],['September','09'],['October','10'],['November','11'],['December','12']]
QUARTER_ARRAY = [['--select--',nil],['January-March','01-03'],['April-June','04-06'],['July-September','07-09'],['October-December','10-12']]


# NOTE: 
# IF IN 
