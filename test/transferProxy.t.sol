// SPDX-License-Identifier: UNLICENSED
// fork test to verify the approval check + calling is working

pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/transferProxy.sol";

contract transferProxyTest is Test {
    transferProxy public proxy;

    // token array for testing
    // owned by _holder
    uint256[] tokens = [55272818262270828949806509515323185841749938423493232502848856346458426498100, 4661079428754936257475530522631516457538021328998370794507429079446456744919, 36727484674670954475716486567814526595488583960969144470214112167822843961144, 85126670798751677352629362719344747409326345842026179112744240673262378153873, 91173369347707073709962225936842248627418674593497431159784899259434692576521, 37447576183557038764643236098890418369163354733642196008261604916734276843314, 26657738737670443899327980282989270847259048966389937657764345488198258331175, 87378514490758657478062485121061853641570751970003057274281331810399368028663, 110105578160567715462776288850412303429042549428466990503041923462819873030712, 24074954706654807663243279158945426528108017175067908040441718327235588406063, 113918329008638486632190643446685058783203869132185978959656007188355724442951, 96040527428425271756986991807478647223400511227599954775623407002418624059368, 64491846121874665456281005734900816940221333987569922815934017574406414399290, 107088994925689234245971259423681695375352697287820393724267465351446826894320, 30188741244517649336625069068085481043020447553184780730917891963474184549033, 63966394722685849384492434286534706386251816177350182258084247928915949879390, 84730683275652029443840000271296642422629977949578118482489714084835396448214, 95051523661380690301852635407025717987101948866195217647832855908315869795679, 3667799992203608174275196385642642672435912554576509621967290796099445852345, 23893844309946520217268791600994312206014527198641351156108006768435480726053, 94264733450650158595697584610336730099833789375156897660360627191426855391352, 71432766370304249323150110289733767430114743143389968077770689013835923890887, 53775476825661660465204309831957339801110789285582126054794760641154502461893, 18774133875541545246225395988457374897320254976207168202750336551786972584578, 108294872574036460309415099135770196681174690070928422958966136622961453357988, 38175456347358560545870595405564159460175878821742815669322556829074487119224, 25551474209403268803546311743278849426618665409766371485834297972337514677587, 103521101546567838293887959800615990995509244754404820830265887008221936831350, 15472481778390259838757933960684278464054587121361007768491848855559433227532, 5588596516639319718337642265937445251858311933293405258258401314129445616019, 72319580538184045199294574455253094703602074520407501632546120276542067252404, 15697731911257742189237259297224453234049749878963375315460471405279503147326, 50843118966933671926812707975992398721923769333574789269816988806347377455966, 57924849671762111055004709743788768039626299672353940886740051273836805951848, 17625457081283528913940870355746325684321623893521757646148271794384514804105, 74195326367910670203200502467135794299072687451778379081832222110377187821412, 78792405042388963116508640104571458205657401411206658425591272322135158057197, 80763125501622352098189283423867544648497378000178637201745558713647506016071, 37005441353168356848466823871896312781514419884551940781626424186221197229362, 70668479442455587444523475751166301976706011640364302926233457754459009895178, 11745081167063551953805831109100572311684149097677171924742531128124637880185, 70913294224351725071897912603875894157217659245080797453249846979541628689973, 34345565176879008152455281367641283436142756110862685522217983704724984544897, 28854719146026833141405635201250218299045598408376813795913838989205634184915, 7310891959843801605732687442457737808908678773201222643279254991064138209700, 106048275004203953209300099743748949942445586188506414213853243190679686349051, 2235974042651240494648846038110591928136039905444693649409983641383961992341, 43247714677737295122235463232212062645641297167749287882305210965648301451297, 17785326412331818278562404734035464752019946288713560262143495420776992613217, 113881540505829802266747860735641431126363474292138312619308927661707742336312, 10749271150824842464038889023635543983222999750789774949945911500582259066671, 27384785020621289861506668053622357550531894862741162546103188883985053555250, 70602687022151497183971271535961821730946346291863781786177266219905469370372, 1349139875316110009314870817973104956173141060559658616587562431759748745724, 53401783926778141432191648708034235250832520813908690565198572440189460787758, 103165442420995917303761035091073579088216442364533829580042124506522410484105, 8228273939130606461332623364164116057563096126903033391072654679427443097655, 12626831519896898258401032672611799095535516197625738197104892084543647454386, 70816395372572743555336478293752737283670527687911255195263493937057998883474, 60222867368988015308816784692081556414218608797875155027067893177430547307081, 82128128231840879033275147879808025241336750599892100523643696697962451005066, 24743162889532412142813681613403002875798823680129056824024379845060255859738, 705044218974370511244243698704496390671402892491903352271775661977455783456, 45499942512356029930677472765545637291920510010576341664807647437167834461315, 72873241140897600541911300053650130502773424887885803517191369191065367749431, 98753160066436574397712350947344980576173865613665973060777603941373013045624, 92074163329026909302577804028302375692112633342688137183765889203603486856171, 68795172741185207458303439421569254235679321009401416654839361977049243579686, 76574171390638392505337843613564015423801026707370226873807068425880841923533, 64452668944511822627743341249031662518902663012098616333356933072674348710337, 109109224550058169248757885494844698072228021921287114206078571104002018360618, 31041814292009409918859741144990590548510491844784156488195240726002346439432, 12911787803867859947136921472092038515761690636450066419043951721120148046933, 35982855052990995442586608907761737279883417837622745982568905818564999716651, 22349532635068716588991282727367527525613158779616663749868821879512708822626];
    // address array for airdrop testing
    address[] addresses;

    // address holding ENS tokens
    address _holder = 0xEf2e1163B1c0c9A271Bd0A08B4f4f65A84255C73;
    address _me = 0x328eBc7bb2ca4Bf4216863042a960E3C64Ed4c10;
    address _ens = 0x57f1887a8BF19b14fC0dF6Fd9B2acc9Af147eA85;

    address _ensERC20 = 0xC18360217D8F7Ab5e7c516566761Ea12Ce7F9D72;

    function setUp() public {
        proxy = new transferProxy();
    }

    event Log(uint256 index, uint256 token);
    bytes32 internal nextUser = keccak256(abi.encodePacked("ABABABAB"));

    function createUsers(uint256 userNum) public returns (address[] memory) {
        address[] memory users = new address[](userNum);
        for (uint256 i = 0; i < userNum; ++i) {
            address user = _getNextUserAddress();
            users[i] = user;
        }
        return users;
    }

    function _getNextUserAddress() internal returns (address) {
        //bytes32 to address conversion
        address user = address(uint160(uint256(nextUser)));
        nextUser = keccak256(abi.encodePacked(nextUser));
        return user;
    }

    function testApprovedCall() public {
        bytes[] memory data = new bytes[](tokens.length);

        // change to the _hacked address to set contract approvals and deal some ETH
        vm.startPrank(_holder);
        vm.deal(_holder, 100 ether);
        vm.deal(_me, 100 ether);

        // set approval for all for _me and proxy to transfer ENS names from _hacked
        (bool success,) = _ens.call(abi.encodeWithSignature("setApprovalForAll(address,bool)", _me, true));
        (bool success2,) = _ens.call(abi.encodeWithSignature("setApprovalForAll(address,bool)", proxy, true));
        require(success && success2, "setApprovalForAll failed");
        vm.stopPrank();

        // change to the _me address to do the Approved transfer / call from _hacked
        vm.startPrank(_me);

        // loop tokens and add them to the data array
        for (uint256 i = 0; i < tokens.length; i++) {
            data[i] = abi.encodeWithSignature("transferFrom(address,address,uint256)", _holder, _me, tokens[i]);
            // emit Log(i, tokens[i]);
        }
        
        proxy.approvedCallUnsafe(data, _ens, _holder);
        vm.stopPrank();
    }

    function testOwnerAirDropERC721() public {
 
        // create users to receive the tokens
        addresses = createUsers(tokens.length);

        // change to the _hacked address to set contract approvals and deal some ETH
        vm.startPrank(_holder);
        vm.deal(_holder, 100 ether);

        (bool success,) = _ens.call(abi.encodeWithSignature("setApprovalForAll(address,bool)", proxy, true));
        require(success, "setApprovalForAll failed");

        // loop tokens and add them to the data array
        
        proxy.ownerAirDropERC721(tokens, addresses, _ens);
        vm.stopPrank();
    }

    // test disperseToken
    function testDisperseToken() public {
        // create users to receive the tokens
        addresses = createUsers(100);

        // change to the _hacked address to set contract approvals and deal some ETH
        vm.startPrank(_holder);
        vm.deal({token: _ensERC20, to: _holder, give: 1000000});

        // (bool success,) = _ens.call(abi.encodeWithSignature("setApprovalForAll(address,bool)", proxy, true));
        // require(success, "setApprovalForAll failed");
        uint256[] memory amounts = new uint256[](addresses.length);
        for (uint256 i = 0; i < addresses.length; i++) {
            amounts[i] = 10000;
        }
        // loop tokens and add them to the data array
        // bytes[] memory data = new bytes[](tokens.length);
        // for (uint256 i = 0; i < tokens.length; i++) {
        //     data[i] = abi.encodeWithSignature("transferFrom(address,address,uint256)", _holder, addresses[i], tokens[i]);
            // emit Log(i, tokens[i]);
        //}
        
        proxy.disperseToken(IERC20(_ensERC20), addresses, amounts);
        vm.stopPrank();
    }

}
