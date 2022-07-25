declare module "rn-user-defaults" {
    function set(key: string, value: any): Promise<void>;
    function get(key: string): Promise<any>;

    function setObjectForKey(key: string, value: object): Promise<void>;
    function objectForKey(key: string): Promise<object>;
}
