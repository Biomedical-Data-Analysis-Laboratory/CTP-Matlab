function patients = getPatientsForExtraction_080520()
%GETPATIENTSFOREXTRACTION_080520 Summary of this function goes here
%   Detailed explanation goes here

root_path = "C:\Users\Luca\OneDrive - Universitetet i Stavanger\Luca\SUS2020_v2\Manual annotations\";
prefix = "superpixels2steps_tree_";


patient1.name = root_path + "CTP_01_001\";
patient1.pm_folder = patient1.name + "IHE_PDI\000091D0\AACCCF5F\AA68AE51\";
patient1.ID = "101001";
patient1.prefix = prefix;
patient1.location = "right";
patient1.coreregion.id = "core";
patient1.coreregion.filepath = patient1.pm_folder + "0000C27B";
patient1.coreregion.savepath = patient1.name + "core\";
patient1.penumbraregion.id = "penumbra";
patient1.penumbraregion.filepath = patient1.pm_folder +"00009B7D";
patient1.penumbraregion.savepath = patient1.name +"penumbra\";

patient4.name = root_path + "CTP_01_004\";
patient4.pm_folder = patient4.name + "IHE_PDI\000079F7\AA322CE0\AA15B9AB\";
patient4.ID = "101004";
patient4.prefix = prefix;
patient4.location = "left";
patient4.coreregion.id = "core";
patient4.coreregion.filepath = patient4.pm_folder + "00000ACA";
patient4.coreregion.savepath = patient4.name + "core\";
patient4.penumbraregion.id = "penumbra";
patient4.penumbraregion.filepath = patient4.pm_folder +"0000153B";
patient4.penumbraregion.savepath = patient4.name +"penumbra\";

patient7.name = root_path + "CTP_01_007\";
patient7.pm_folder = patient7.name + "IHE_PDI\00008994\AAECE84F\AA14BEB9\";
patient7.ID = "101007";
patient7.prefix = prefix;
patient7.location = "right";
patient7.coreregion.id = "core";
patient7.coreregion.filepath = patient7.pm_folder + "000053EB";
patient7.coreregion.savepath = patient7.name + "core\";
patient7.penumbraregion.id = "penumbra";
patient7.penumbraregion.filepath = patient7.pm_folder +"0000D637";
patient7.penumbraregion.savepath = patient7.name +"penumbra\";

patient10.name = root_path + "CTP_01_010\";
patient10.pm_folder = patient10.name + "IHE_PDI\00004659\AA1C1964\AAF0B084\";
patient10.ID = "101010";
patient10.prefix = prefix;
patient10.location = "right";
patient10.coreregion.id = "core";
patient10.coreregion.filepath = patient10.pm_folder + "000015DA";
patient10.coreregion.savepath = patient10.name + "core\";
patient10.penumbraregion.id = "penumbra";
patient10.penumbraregion.filepath = patient10.pm_folder +"0000615F";
patient10.penumbraregion.savepath = patient10.name +"penumbra\";

patient13.name = root_path + "CTP_01_013\";
patient13.pm_folder = patient13.name + "IHE_PDI\000080C3\AA28C453\AA6A0C3F\";
patient13.ID = "101013";
patient13.prefix = prefix;
patient13.location = "right";
patient13.coreregion.id = "core";
patient13.coreregion.filepath = patient13.pm_folder + "0000068F";
patient13.coreregion.savepath = patient13.name + "core\";
patient13.penumbraregion.id = "penumbra";
patient13.penumbraregion.filepath = patient13.pm_folder +"000076CE";
patient13.penumbraregion.savepath = patient13.name +"penumbra\";

patient16.name = root_path + "CTP_01_016\";
patient16.pm_folder = patient16.name + "IHE_PDI\000057C0\AAF65C1D\AA217AD9\";
patient16.ID = "101016";
patient16.prefix = prefix;
patient16.location = "right";
patient16.coreregion.id = "core";
patient16.coreregion.filepath = patient16.pm_folder + "00007784";
patient16.coreregion.savepath = patient16.name + "core\";
patient16.penumbraregion.id = "penumbra";
patient16.penumbraregion.filepath = patient16.pm_folder +"0000841E";
patient16.penumbraregion.savepath = patient16.name +"penumbra\";

patient19.name = root_path + "CTP_01_019\";
patient19.pm_folder = patient19.name + "IHE_PDI\0000C5C2\AA6FDF5D\AAB07678\";
patient19.ID = "101019";
patient19.prefix = prefix;
patient19.location = "right";
patient19.coreregion.id = "core";
patient19.coreregion.filepath = patient19.pm_folder + "0000531C";
patient19.coreregion.savepath = patient19.name + "core\";
patient19.penumbraregion.id = "penumbra";
patient19.penumbraregion.filepath = patient19.pm_folder +"0000442A";
patient19.penumbraregion.savepath = patient19.name +"penumbra\";

% patient22.name = root_path + "CTP_01_022\";
% patient22.pm_folder = patient22.name + "IHE_PDI\0000B04F\AAA633BC\AA12DFAE\";
% patient22.ID = "101022";
% patient22.prefix = prefix;
% patient22.location = "left";
% patient22.coreregion.id = "core";
% patient22.coreregion.filepath = patient22.pm_folder + "0000531C";
% patient22.coreregion.savepath = patient22.name + "core\";
% patient22.penumbraregion.id = "penumbra";
% patient22.penumbraregion.filepath = patient22.pm_folder +"00000C5B";
% patient22.penumbraregion.savepath = patient22.name +"penumbra\";

patient25.name = root_path + "CTP_01_025\";
patient25.pm_folder = patient25.name + "IHE_PDI\0000BD6A\AA134C2E\AA6A4A03\";
patient25.ID = "101025";
patient25.prefix = prefix;
patient25.location = "left";
patient25.coreregion.id = "core";
patient25.coreregion.filepath = patient25.pm_folder + "0000C5BB";
patient25.coreregion.savepath = patient25.name + "core\";
patient25.penumbraregion.id = "penumbra";
patient25.penumbraregion.filepath = patient25.pm_folder +"0000CDCF";
patient25.penumbraregion.savepath = patient25.name +"penumbra\";

patient201.name = root_path + "CTP_02_001\";
patient201.pm_folder = patient201.name + "IHE_PDI\00001B7E\AAC64044\AACBB660\";
patient201.ID = "102001";
patient201.prefix = prefix;
patient201.location = "right";
patient201.coreregion.id = "core";
patient201.coreregion.filepath = patient201.pm_folder + "0000FFF0";
patient201.coreregion.savepath = patient201.name + "core\";
patient201.penumbraregion.id = "penumbra";
patient201.penumbraregion.filepath = patient201.pm_folder +"00007753";
patient201.penumbraregion.savepath = patient201.name +"penumbra\";

patient204.name = root_path + "CTP_02_004\";
patient204.pm_folder = patient204.name + "IHE_PDI\00004966\AAE386E2\AA1BB2FD\";
patient204.ID = "102004";
patient204.prefix = prefix;
patient204.location = "left";
patient204.coreregion.id = "core";
patient204.coreregion.filepath = patient204.pm_folder + "0000F262";
patient204.coreregion.savepath = patient204.name + "core\";
patient204.penumbraregion.id = "penumbra";
patient204.penumbraregion.filepath = patient204.pm_folder +"0000180F";
patient204.penumbraregion.savepath = patient204.name +"penumbra\";

patient207.name = root_path + "CTP_02_007\";
patient207.pm_folder = patient207.name + "IHE_PDI\0000793C\AA2B0B58\AA284FF1\";
patient207.ID = "102007";
patient207.prefix = prefix;
patient207.location = "right";
patient207.coreregion.id = "core";
patient207.coreregion.filepath = patient207.pm_folder + "0000410C";
patient207.coreregion.savepath = patient207.name + "core\";
patient207.penumbraregion.id = "penumbra";
patient207.penumbraregion.filepath = patient207.pm_folder +"000095C2";
patient207.penumbraregion.savepath = patient207.name +"penumbra\";

patient210.name = root_path + "CTP_02_010\";
patient210.pm_folder = patient210.name + "IHE_PDI\0000E917\AA753026\AA10AAEC\";
patient210.ID = "102010";
patient210.prefix = prefix;
patient210.location = "left";
patient210.coreregion.id = "core";
patient210.coreregion.filepath = patient210.pm_folder + "0000CA7E";
patient210.coreregion.savepath = patient210.name + "core\";
patient210.penumbraregion.id = "penumbra";
patient210.penumbraregion.filepath = patient210.pm_folder +"000056CA";
patient210.penumbraregion.savepath = patient210.name +"penumbra\";
% same as the previous one, different ID
patient210bis.name = root_path + "CTP_02_010\";
patient210bis.pm_folder = patient210bis.name + "IHE_PDI\0000E917\AA753026\AA10AAEC\";
patient210bis.ID = "202010";
patient210bis.prefix = prefix;
patient210bis.location = "left";
patient210bis.coreregion.id = "core";
patient210bis.coreregion.filepath = patient210bis.pm_folder + "0000CA7E";
patient210bis.coreregion.savepath = patient210bis.name + "core\";
patient210bis.penumbraregion.id = "penumbra";
patient210bis.penumbraregion.filepath = patient210bis.pm_folder +"000056CA";
patient210bis.penumbraregion.savepath = patient210bis.name +"penumbra\";

patient213.name = root_path + "CTP_02_013\";
patient213.pm_folder = patient213.name + "IHE_PDI\00002578\AAFCECC4\AA0E943E\";
patient213.ID = "202013";
patient213.prefix = prefix;
patient213.location = "left";
patient213.coreregion.id = "core";
patient213.coreregion.filepath = patient213.pm_folder + "0000FCBD";
patient213.coreregion.savepath = patient213.name + "core\";
patient213.penumbraregion.id = "penumbra";
patient213.penumbraregion.filepath = patient213.pm_folder +"0000E9CB";
patient213.penumbraregion.savepath = patient213.name +"penumbra\";

patient216.name = root_path + "CTP_02_016\";
patient216.pm_folder = patient216.name + "IHE_PDI\0000768E\AAB999BA\AAB124EC\";
patient216.ID = "102016";
patient216.prefix = prefix;
patient216.location = "left";
patient216.coreregion.id = "core";
patient216.coreregion.filepath = patient216.pm_folder + "0000348F";
patient216.coreregion.savepath = patient216.name + "core\";
patient216.penumbraregion.id = "penumbra";
patient216.penumbraregion.filepath = patient216.pm_folder +"00007797";
patient216.penumbraregion.savepath = patient216.name +"penumbra\";

patient219.name = root_path + "CTP_02_019\";
patient219.pm_folder = patient219.name + "IHE_PDI\0000B06D\AA2F76BB\AA0D9C10\";
patient219.ID = "102019";
patient219.prefix = prefix;
patient219.location = "right";
patient219.coreregion.id = "core";
patient219.coreregion.filepath = patient219.pm_folder + "0000C6B8";
patient219.coreregion.savepath = patient219.name + "core\";
patient219.penumbraregion.id = "penumbra";
patient219.penumbraregion.filepath = patient219.pm_folder +"0000E2FD";
patient219.penumbraregion.savepath = patient219.name +"penumbra\";

patient222.name = root_path + "CTP_02_022\";
patient222.pm_folder = patient222.name + "IHE_PDI\00009AEB\AAC7BAE6\AAC3C9B6\";
patient222.ID = "102022";
patient222.prefix = prefix;
patient222.location = "left";
patient222.coreregion.id = "core";
patient222.coreregion.filepath = patient222.pm_folder + "000001FC";
patient222.coreregion.savepath = patient222.name + "core\";
patient222.penumbraregion.id = "penumbra";
patient222.penumbraregion.filepath = patient222.pm_folder +"00007E03";
patient222.penumbraregion.savepath = patient222.name +"penumbra\";

patient225.name = root_path + "CTP_02_025\";
patient225.pm_folder = patient225.name + "IHE_PDI\00002839\AABF5A19\AA69C523\";
patient225.ID = "102025";
patient225.prefix = prefix;
patient225.location = "left";
patient225.coreregion.id = "core";
patient225.coreregion.filepath = patient225.pm_folder + "00003992";
patient225.coreregion.savepath = patient225.name + "core\";
patient225.penumbraregion.id = "penumbra";
patient225.penumbraregion.filepath = patient225.pm_folder +"0000971D";
patient225.penumbraregion.savepath = patient225.name +"penumbra\";

patient228.name = root_path + "CTP_02_028\";
patient228.pm_folder = patient228.name + "IHE_PDI\0000FC68\AA4950B8\AA43D924\";
patient228.ID = "102028";
patient228.prefix = prefix;
patient228.location = "right";
patient228.coreregion.id = "core";
patient228.coreregion.filepath = patient228.pm_folder + "0000D19A";
patient228.coreregion.savepath = patient228.name + "core\";
patient228.penumbraregion.id = "penumbra";
patient228.penumbraregion.filepath = patient228.pm_folder +"0000606E";
patient228.penumbraregion.savepath = patient228.name +"penumbra\";


patients = [patient1, patient4, patient7, patient10, patient13, patient16, patient19, patient25, ...
    patient201, patient204, patient207, patient210, patient210bis, patient213, patient216, patient219, patient222, patient225, patient228];


end

