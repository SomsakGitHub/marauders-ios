//import Combine
//
//class LoginSceneViewModel: ObservableObject {
//    var isLoggedIn = false
//    @Published var username: String = ""
//    @Published var password: String = ""
//    
//    private let service = LoginService()
//    private let disposeBag = DisposeBag()
//    
//    func login(completion: @escaping (Bool) -> Void) {
//        service.login(req: LoginReq(email: "", password: ""))
//            .subscribe { res in
//                completion(true)
//            } onError: { error in
////                completion(.failure(error))
//            }.disposed(by: disposeBag)
//    }
//}
