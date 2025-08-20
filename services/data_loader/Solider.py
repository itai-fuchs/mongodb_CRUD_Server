

class Solider:

    def __init__(self,id,firstName,lastName,phone_number,rank):
       self.id =id
       self.firstName=firstName
       self.lastName=lastName
       self.phone_number=phone_number
       self.rank=rank

    def convert_to_json(self):
        return {"id":self.id,
                "firstName":self.firstName,
                "lastName":self.lastName,
                "phone_number":self.phone_number,
                "rank":self.rank}