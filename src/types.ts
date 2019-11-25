export default class JWTModel {
    token: string;
}

export interface Pronouns {
    subject: string;
    object: string;
    possesive: string;
}

export interface Social {
    name: string;
    link: string;
}

export interface Runner {
    user: string;
    country: string;
    flavourText: string;
    social: Social[];
}

export interface UserInfo {
    id: string;
    display_name: string;
    verified: boolean;
    pronouns: Pronouns;
}