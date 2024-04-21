import { Person } from "@/models/person.models";
import { Avatar } from "antd";


export default function RoundedAvatar(params: { person: Person, size?: 'lg' | 'small', bg?: string }): JSX.Element {
  return <div className="flex flex-col items-center gap-1 md:hover:opacity-50 cursor-pointer">
    <div className={`p-1 w-fit h-fit rounded-full ${params.bg || 'bg-third' }`}>
      <Avatar src={params.person.profile} className={`${params.size === 'lg' ?  'w-14 h-14' : 'w-8 h-8'}`} />
    </div>
    <p className={`text-center ${params.size === 'lg' ? 'text-normal' : 'text-sm'}`}>{ params.person.name || '-' }</p>
  </div>
}